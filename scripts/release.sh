#!/usr/bin/env bash
# Tag a release and push the tag, which triggers the CD workflow.
#
# Usage: scripts/release.sh [--dry-run] [--yes] <patch|minor|major|X.Y.Z>
set -euo pipefail

BRANCH=main
REMOTE=origin

usage() {
	cat <<EOF
Usage: $(basename "$0") [--dry-run] [--yes] <patch|minor|major|X.Y.Z>

Creates an annotated tag vX.Y.Z on $BRANCH and pushes it to $REMOTE.

  patch|minor|major  Bump the latest vX.Y.Z tag
  X.Y.Z              Use this exact version (a leading "v" is optional)
  -n, --dry-run      Run all checks and show what would happen, change nothing
  -y, --yes          Don't ask for confirmation
  -h, --help         Show this help
EOF
}

die() {
	echo "error: $*" >&2
	exit 1
}

run() {
	if [[ $dry_run == true ]]; then
		echo "[dry-run] $*"
	else
		"$@"
	fi
}

dry_run=false
assume_yes=false
version_arg=""

while [[ $# -gt 0 ]]; do
	case "$1" in
	-n | --dry-run) dry_run=true ;;
	-y | --yes) assume_yes=true ;;
	-h | --help)
		usage
		exit 0
		;;
	-*) die "unknown option: $1" ;;
	*)
		[[ -z $version_arg ]] || die "only one version may be given"
		version_arg=$1
		;;
	esac
	shift
done

[[ -n $version_arg ]] || {
	usage >&2
	exit 1
}

cd "$(git rev-parse --show-toplevel)"

# --- Repository checks -------------------------------------------------------

current_branch=$(git symbolic-ref --short -q HEAD || true)
[[ $current_branch == "$BRANCH" ]] || die "must be on $BRANCH (currently on ${current_branch:-a detached HEAD})"

[[ -z $(git status --porcelain) ]] || die "working tree is not clean; commit or stash your changes first"

echo "Fetching $REMOTE..."
git fetch --quiet --tags "$REMOTE" "$BRANCH"

local_sha=$(git rev-parse HEAD)
remote_sha=$(git rev-parse "$REMOTE/$BRANCH")
if [[ $local_sha != "$remote_sha" ]]; then
	base_sha=$(git merge-base HEAD "$REMOTE/$BRANCH")
	if [[ $base_sha == "$local_sha" ]]; then
		die "$BRANCH is behind $REMOTE/$BRANCH; pull first"
	elif [[ $base_sha == "$remote_sha" ]]; then
		die "$BRANCH has unpushed commits; push them first so the tag points at a published commit"
	else
		die "$BRANCH and $REMOTE/$BRANCH have diverged"
	fi
fi

# --- Version ------------------------------------------------------------------

semver='^([0-9]+)\.([0-9]+)\.([0-9]+)$'

latest_tag=$(git tag --list 'v[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | head -n 1 || true)
latest=${latest_tag#v}
latest=${latest:-0.0.0}
[[ $latest =~ $semver ]]
major=${BASH_REMATCH[1]} minor=${BASH_REMATCH[2]} patch=${BASH_REMATCH[3]}

case "$version_arg" in
patch) version="$major.$minor.$((patch + 1))" ;;
minor) version="$major.$((minor + 1)).0" ;;
major) version="$((major + 1)).0.0" ;;
*)
	version=${version_arg#v}
	[[ $version =~ $semver ]] || die "invalid version '$version_arg' (expected X.Y.Z, patch, minor or major)"
	;;
esac
tag="v$version"

if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
	die "tag $tag already exists"
fi

if [[ -n $latest_tag ]]; then
	highest=$(printf '%s\n%s\n' "$latest" "$version" | sort -V | tail -n 1)
	[[ $highest == "$version" ]] || die "$tag is not newer than the latest tag $latest_tag"
fi

# --- Release ------------------------------------------------------------------

echo
echo "Latest tag:  ${latest_tag:-(none)}"
echo "New tag:     $tag"
echo "Commit:      $(git log -1 --format='%h %s')"
if [[ -n $latest_tag ]]; then
	echo "Changes:     $(git rev-list --count "$latest_tag..HEAD") commit(s) since $latest_tag"
fi
echo

if [[ $dry_run == false && $assume_yes == false ]]; then
	read -r -p "Create and push $tag to $REMOTE? [y/N] " reply || reply=""
	[[ $reply =~ ^[Yy]$ ]] || die "aborted (pass --yes to skip this prompt)"
fi

run git tag --annotate "$tag" --message "Release $tag"
run git push "$REMOTE" "refs/tags/$tag"

if [[ $dry_run == true ]]; then
	echo
	echo "Dry run complete; nothing was changed."
else
	echo
	echo "Pushed $tag. The CD workflow will now build and publish the release."
fi
