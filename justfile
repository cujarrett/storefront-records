# lint -> test -> build, what CI runs before an image exists
ci: lint test build

lint:
    npm run lint

test:
    npm run test

build:
    npm run build

install:
    npm install

# this subgraph from source, every other schema pulled from the test variant
dev:
    APOLLO_ELV2_LICENSE=accept rover dev --graph-ref storefront-homelab@test --supergraph-config override.yaml

# does this compose against the test variant, and does it break a real operation
check:
    rover subgraph check storefront-homelab@test --name records --schema schema.graphql
