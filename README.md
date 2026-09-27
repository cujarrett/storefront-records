# storefront-records

The `records` subgraph of `storefront-homelab`. Owns the `Record` type. One team, one repo, one schema file beside the resolvers that serve it.

How it reaches the graph: [Platform Graph](https://github.com/cujarrett/homelab/blob/main/platform/docs/graph.md). The walkthrough is at [graph.mattjarrett.dev](https://graph.mattjarrett.dev).

## Where it runs

Two files in `homelab-workspaces`, one per lane. CI writes the test digest, and `just promote` moves it to prod by pull request. Each file is a `GraphApi`, which the platform renders into the pod, its mesh policy and the Apollo `Subgraph` that publishes this schema.

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

```bash
just promote
```

Opens a PR in `homelab-workspaces` moving the digest running in test into `graph-prod`, after confirming the schema still composes against `storefront-homelab@prod`.
