# Po-sen Tap

This tap tracks installable versions of tools I commonly rely on. Formulae stay
under `Formula/`, while tracking policy and maintenance commands live in
`config/`, `docs/`, and `script/`.

## How do I install these formulae?

`brew install po-sen/tap/<formula>`

Or `brew tap po-sen/tap` and then `brew install <formula>`.

Or, in a [`brew bundle`](https://github.com/Homebrew/homebrew-bundle) `Brewfile`:

```ruby
tap "po-sen/tap"
brew "<formula>"
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).

## Tracked projects

Tracked package metadata is defined in `config/tracked-packages.yml`. The full
upstream version catalog is stored in `data/upstream-versions.yml`.

See `docs/tracked-projects.md` for the package list, tracking model, and update
workflow.

Useful maintenance commands:

```sh
script/tracked-versions
script/update-version-catalog
script/livecheck
script/check
```
