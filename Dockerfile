FROM --platform=$BUILDPLATFORM golang:1.27-alpine@sha256:d200d2dd76b03a99b52651fd1325aff7dcd35422c35c01bac56571b0507f3deb AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go tool gqlgen generate
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -ldflags="-s -w" -o storefront-records .

# Moves to ghcr.io/cujarrett/base-go once it publishes (homelab#416).
FROM gcr.io/distroless/static-debian13:nonroot@sha256:25ac8f0c3b2334a9eb05452266bd4697864a8c8ef0ef71e5e6480d7f92868329
COPY --from=builder /app/storefront-records /storefront-records
# The platform reads the schema from this path in the image and publishes it.
COPY schema.graphql /schema.graphql
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/storefront-records"]
