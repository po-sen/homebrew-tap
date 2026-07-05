# Tracked Projects

This tap is the install and version-tracking surface for tools that should be quick to recover, debug, or pin.

## Tracking Model

- `config/tracked-packages.yml` is the source of truth for upstream repositories, tag matching, and formula policy.
- `data/upstream-versions.yml` records every matching upstream version currently known to the tap.
- `Formula/<name>.rb` is the primary formula for the default version installed by `brew install <name>`.
- `Formula/<name>@<version>.rb` is reserved for versions that must remain directly installable.
- Upstream history is tracked from GitHub tags and persisted in the catalog. The tap does not create a formula for every historical tag by default.

This keeps the repo scalable: tracking every upstream version is cheap, while maintaining installable formulae stays intentional.

## Current Packages

| Package | Upstream | Primary formula | Pinned formulae |
| --- | --- | --- | --- |
| asdf | `asdf-vm/asdf` | `asdf` | `asdf@0.17.0` |
| Neovim | `neovim/neovim` | `neovim` | none |

## Common Commands

List the latest tracked upstream versions:

```sh
script/tracked-versions
```

List all matching upstream versions:

```sh
script/tracked-versions --all
```

Regenerate the persisted version catalog:

```sh
script/update-version-catalog
```

Verify the catalog is current:

```sh
script/update-version-catalog --check
```

Run Homebrew livecheck for this tap:

```sh
script/livecheck
```

Run local validation before pushing:

```sh
script/check
```

## Adding A Package

1. Add the package to `config/tracked-packages.yml`.
2. Add the primary formula under `Formula/<name>.rb`.
3. Add versioned formulae only for versions that need to stay installable.
4. Run `script/tracked-versions <package>` to confirm tag matching.
5. Run `script/update-version-catalog`.
6. Run `script/check`.

## Updating A Formula

1. Check upstream versions with `script/tracked-versions <package>`.
2. Check Homebrew's view with `script/livecheck`.
3. Update the formula URL, tag, revision, sha256, resources, and tests as needed.
4. For Neovim, review `cmake.deps/CMakeLists.txt` in the target upstream tag and update tree-sitter resources.
5. Regenerate the catalog with `script/update-version-catalog` if upstream tags changed.
6. Run `script/check`.
