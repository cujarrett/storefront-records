# storefront-records

The `records` subgraph of `storefront-homelab`. Owns the `Record` type. One team, one repo, one schema file beside the resolvers that serve it.

How it reaches the graph: [Platform Graph](https://github.com/cujarrett/homelab/blob/main/platform/docs/graph.md). The walkthrough is at [graph.mattjarrett.dev](https://graph.mattjarrett.dev).

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
