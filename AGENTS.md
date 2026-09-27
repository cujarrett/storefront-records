# storefront-records

One subgraph of the `storefront-homelab` federated graph, owned by one team. See [Platform Graph](https://github.com/cujarrett/homelab/blob/main/platform/docs/graph.md) in the `homelab` repo for how it reaches the graph.

## Rules

- **Never run `git add`, `git commit`, `git push`, or any git command that writes to or modifies the index, repository history, or remotes.** Output the commands for the user to run - staging is part of their review, and running it for them removes the checkpoint.
- **Never add a `Co-Authored-By` trailer or a "Generated with Claude Code" line** to commit messages or PR descriptions, including in suggested commit messages. Commits are authored by the user alone.
- **Whenever a task requires a commit, always give a suggested commit message** - never leave the user to write it themselves.
- **Give `git add` and the commit as two separate steps, listing every file explicitly.** Never `git add .` or `git add -A`.
- **Never output a `git push` command.** The user pushes as a deliberate human step.
- **No semicolons in JS/TS.** Enforced by Prettier (`semi: false`) and ESLint (`semi: ["error", "never"]`).
- **The platform publishes the schema from the deployed image.** Nothing in this repo runs `rover subgraph publish`. The image ships `schema.graphql` at `/schema.graphql`. See [How the schema reaches the registry](https://github.com/cujarrett/homelab/blob/main/platform/docs/graph.md#2-how-the-schema-reaches-the-registry).

### Pre-commit safety check

Before telling the user to commit, always run `/security-review`. Once it confirms the changes are safe, offer a suggested commit message - do not run `git commit` yourself.

## Philosophy: Grug-Brained Development

> "Complexity very, very bad." - [grugbrain.dev](https://grugbrain.dev/)

- **Say no.** No new feature, no new abstraction, until it earns its place.
- **Cheapest rung that works.** Skip the feature, reuse code already here, standard library, native platform feature, a dependency already installed, one line, then build the minimum.
- **80/20 solutions.** Ugly but working beats elegant but over-engineered.
- **No FOLD** (Fear Of Looking Dumb). If something is too complex, say so.

## Build tool: `just`, not `make`

`just --list` shows every recipe. `just ci` before pushing. `just check` runs the schema check against the test variant, the same one CI runs.

## CI

`ci.yml`: `test` and `schema-check` on every PR, both required by branch protection. On main, `build-and-push` signs the image by digest and `deploy` writes that digest to `graph-test/records.yaml` in `homelab-workspaces`. `promote.yml` opens the PR that moves it to `graph-prod`.

## Required secrets (GitHub → repo settings → Secrets)

- `APOLLO_KEY`: a GraphOS key that can run schema checks.
- `HOMELAB_WORKSPACES_PAT`: writes the digest to `homelab-workspaces`. Rotated by the homelab script, which finds every repo holding it.
