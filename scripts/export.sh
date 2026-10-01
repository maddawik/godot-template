#!/usr/bin/env bash
# Export every preset in export_presets.cfg to its export_path, then archive
# each one as out/<preset name>.zip. Requires export templates to be installed.
set -euo pipefail

cd "$(dirname "$0")/.."

while IFS=$'\t' read -r preset export_path; do
	export_dir=$(dirname "$export_path")
	archive="out/$preset.zip"

	echo "Exporting $preset to $export_path"
	rm -rf "$export_dir" "$archive"
	mkdir -p "$export_dir"
	godot --headless --export-release "$preset" "$export_path" </dev/null

	# macOS presets export straight to a .zip, so don't zip it twice.
	if [[ "$export_path" == *.zip ]]; then
		cp "$export_path" "$archive"
	else
		(cd "$export_dir" && zip -qr "$OLDPWD/$archive" .)
	fi
done < <(awk -F= '/^name=/ { name = $2 } /^export_path=/ { print name "\t" $2 }' export_presets.cfg | tr -d '"')
