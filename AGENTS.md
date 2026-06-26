# AGENTS.md

## Repository

Homebrew tap for [frantic1048](https://github.com/frantic1048)'s projects.
Formulae distribute pre-built binaries from GitHub Releases.

## Conventions

- **Branches**: `dev/*` for all work branches
- **Commits**: single commit per PR
- **Language**: English for code, comments, docs, and commit messages
- **Formulae**: pre-built binary distribution from GitHub Releases; no source builds

## Structure

```
Formula/                                # One .rb file per tool
.github/scripts/update-formula.py       # Formula update logic (called by workflow)
.github/workflows/update-formula.yml    # Version bump automation (dispatch-triggered)
```

## How Formula Updates Work

The tap receives `repository_dispatch` events from upstream release workflows:

1. Upstream repo (e.g. Vanilla) completes a release build
2. Release workflow sends `repository_dispatch` with `{formula, version}` payload
3. `update-formula.yml` downloads SHA256 checksums from the release assets
4. Workflow updates the formula and opens a PR on `dev/update-<name>-v<version>`

Manual trigger via `workflow_dispatch` is also available (Actions → Run workflow).

## Adding a New Formula

1. Create `Formula/<name>.rb` following the existing `blend.rb` pattern
2. Use pre-built binaries from GitHub Releases with per-platform `url` + `sha256`
3. Include a `livecheck` block with the tag regex for version detection
4. Include a `test` block for basic verification (e.g. `--version` output)
5. The update workflow auto-detects the source repo and tag prefix from the formula's `url`,
   so new formulae work without workflow changes as long as the release provides a `sha256.sum`
