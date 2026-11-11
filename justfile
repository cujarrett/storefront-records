# generate -> lint -> test -> build, what CI runs before an image exists
ci: lint test build

# graph/ from schema.graphql. Run after editing the schema.
generate:
    go tool gqlgen generate

lint: generate
    go mod tidy -diff
    golangci-lint run

test: generate
    go test -race ./...

build: generate
    go build -race -o storefront-records .

run: generate
    go run .

# this subgraph from source, every other schema pulled from the test variant
dev:
    APOLLO_ELV2_LICENSE=accept rover dev --graph-ref storefront-homelab@test --supergraph-config override.yaml

# does this compose against the test variant, and does it break a real operation
check:
    rover subgraph check storefront-homelab@test --name records --schema schema.graphql
