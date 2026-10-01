# Godot Template

A batteries-included template for quickly starting a game with the Godot Engine.

![Godot](https://img.shields.io/badge/Godot-4.7.2-blue)
![GUT](https://img.shields.io/badge/GUT-9.7.1-green)

## Batteries Included 🔋

- Export presets for HTML5, Linux, Windows, and macOS
- Includes [GUT](https://github.com/bitwes/Gut) for testing
- Provides continuous integration by running tests against pull requests
- Release workflow publishes GitHub Releases and uploads builds to itch.io

## Getting Started 🎮

### Setup

1. Create a new project on [itch.io](https://itch.io).
2. Create a new repository from this template.
3. In GitHub, add the following **repository secret**:
   **Settings → Secrets and variables → Actions → Secrets**

```sh
# Find this in itch.io: Account → Settings → API Keys
BUTLER_API_KEY=YourButlerAPIKey
```

<!-- markdownlint-disable-next-line MD029 -->
4. Add the following **repository variables**:
   **Settings → Secrets and variables → Actions → Variables**

```sh
ITCH_NAME=YourItchUsername
ITCH_GAME=YourItchProject
```

<!-- markdownlint-disable-next-line MD029 -->
5. In Godot, open **Project → Export → MacOS** and change
   **Application → Bundle Identifier** from the placeholder `com.godot.game`
   to your own (e.g. `com.yourname.yourgame`).

### Publishing

Now you can publish new releases of your game by pushing git tags.

> [!NOTE]
> Only tags that start with `v` will trigger a release

Use `scripts/release.sh` to create and push the tag. It checks that you're on
an up-to-date, clean `main`, picks the next version, and asks before pushing.

```sh
# Preview the next patch release without changing anything
./scripts/release.sh --dry-run patch

# Release it (or use minor, major, or an exact version like 1.2.0)
./scripts/release.sh patch
```

This creates a GitHub Release with build artifacts and uploads them to your
itch.io project. After the first upload, you can configure the project to be
[web-playable](https://itch.io/docs/butler/pushing.html#html--playable-in-browser-games).
