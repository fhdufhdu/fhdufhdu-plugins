# Skill/Data Repository Split Design

## Context

The current repository, `/Users/fhdufhdu/project/book-jak-book-jak`, contains both the English reading study skill and private study data. The data repository already exists at `/Users/fhdufhdu/project/book-jak-book-jak-data` and currently has no committed data.

The goal is to split the project into:

- A skill/plugin distribution repository: `fhdufhdu/book-jak-book-jak`
- A data repository: `fhdufhdu/book-jak-book-jak-data`

The data repository does not need to preserve historical commits. The skill repository should not retain study data in its Git history.

## Architecture

The skill repository remains the distribution source for the English reading study workflow. It keeps only skill, plugin, marketplace, and documentation files:

- `README.md`
- `skills/english-reading-study/SKILL.md`
- `skills/english-reading-study/references/record-schema.md`
- Codex plugin metadata
- Claude Code plugin metadata
- Marketplace metadata for command-based registration

The data repository becomes the source of truth for study records. It receives the current snapshot of these directories as its initial data commit:

- `daily/`
- `reviews/`
- `cards/`
- `sources/`
- `persistent/`

The skill continues to use `~/.english-reading-study/info.json` and `~/.english-reading-study/repo` as documented. On first use, it asks the user for the study data Git repository URL and clones that repository into the local data checkout.

## Repository History

The skill repository history must be rewritten to remove study data paths from every commit:

- `daily/`
- `reviews/`
- `cards/`
- `sources/`
- `persistent/`

The preferred implementation is `git filter-repo` with those paths inverted out of history. After rewriting, the remote `main` branch requires a force push. Existing clones of the skill repository may need to be recloned or manually repaired after the force push.

The data repository starts from the current working snapshot only. It does not import commit history from the original repository.

## Codex Distribution

The README should describe Codex registration through Codex's plugin/marketplace surfaces, not by asking users to manually clone this repository.

Supported Codex paths:

1. Codex app: use the Plugins UI to add/register the marketplace or plugin source, then enable the English reading study plugin/skill.
2. Codex CLI direct command:

   ```bash
   codex plugin marketplace add fhdufhdu/book-jak-book-jak
   ```

3. Codex CLI update command:

   ```bash
   codex plugin marketplace upgrade
   ```

The local Codex CLI currently reports `codex-cli 0.128.0`, whose help confirms `codex plugin marketplace add <SOURCE>` accepts `owner/repo[@ref]`, HTTP(S) Git URLs, SSH URLs, or local marketplace root directories.

If a separate Codex Marketplace command is mentioned, it should be clearly marked as an alternate compatibility path rather than the primary installation method.

## Claude Code Distribution

The repository should also be structured as a Claude Code plugin/marketplace source.

The README should describe official command-based registration, not manual cloning:

```bash
claude plugin marketplace add fhdufhdu/book-jak-book-jak
```

It should also mention the in-session equivalent:

```text
/plugin marketplace add fhdufhdu/book-jak-book-jak
```

After the marketplace is added, users install the plugin from that marketplace using the Claude Code plugin install flow, for example:

```text
/plugin install english-reading-study@book-jak-book-jak
```

The Claude marketplace manifest should use `book-jak-book-jak` as its marketplace name.

## README Updates

The README should explain:

- This repository distributes the skill/plugin only.
- Study data lives in `fhdufhdu/book-jak-book-jak-data`.
- Users should register the plugin through Codex app, Codex CLI, or Claude Code plugin marketplace commands.
- Users should not install the skill by manually cloning the repository into a skill directory.
- On first study session, the skill asks for the data repository URL and stores that configuration under `~/.english-reading-study/info.json`.
- The data checkout lives at `~/.english-reading-study/repo`.

## Error Handling

Before making repository changes, inspect both repositories for unexpected local changes. Preserve unrelated user changes.

If `git filter-repo` is unavailable, use the shortest safe alternative:

1. Install `git-filter-repo` temporarily.
2. Run the history rewrite.
3. Remove `git-filter-repo` after rewrite and verification.
4. If temporary installation fails, stop and report the blocker before rewriting history.

If pushing fails because authentication is unavailable, keep local changes and report the exact command that still needs to be run.

## Minimal Verification

Verification should stay intentionally small:

- Confirm the data repository contains the expected top-level data directories.
- Confirm the skill repository no longer contains data directories in the working tree.
- Confirm the skill repository history no longer reports those data paths with:

  ```bash
  git log --all -- daily reviews cards sources persistent
  ```

- Confirm relevant JSON manifests parse successfully.
- Run `claude plugin validate .` only if the `claude` command is available.

No broad test suite is required for this migration.
