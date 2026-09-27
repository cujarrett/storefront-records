# storefront-records

The `records` subgraph of `storefront-homelab`. Owns the `Record` type. One team, one repo, one schema file beside the resolvers that serve it.

How it reaches the graph: [Platform Graph](https://github.com/cujarrett/homelab/blob/main/platform/docs/graph.md). The walkthrough is at [graph.mattjarrett.dev](https://graph.mattjarrett.dev).

## Where it runs

Two files in `homelab-workspaces`, one per lane. CI writes the test digest, then opens a pull request moving that digest to prod. Merging it is the promotion. Each file is a `GraphApi`, which the platform renders into the pod, its mesh policy and the Apollo `Subgraph` that publishes this schema.

- [graph-test/records.yaml](https://github.com/cujarrett/homelab-workspaces/blob/main/graph-test/records.yaml)
- [graph-prod/records.yaml](https://github.com/cujarrett/homelab-workspaces/blob/main/graph-prod/records.yaml)

## Run it locally

```bash
just install
npm run dev &     # this subgraph on :4001
just dev          # composes it with every other subgraph published to test
```

## Before opening a PR

```bash
just ci
just check
```

## Promoting to prod

Every merge to main deploys to test and opens, or updates, the `promote-records` pull request in `homelab-workspaces`. It has already passed the schema check against `storefront-homelab@prod`. Review and merge it.
