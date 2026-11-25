FROM --platform=$BUILDPLATFORM golang:1.27-alpine@sha256:70bd7ddea8b6cbe5d6943cde279d6b67feb10cc924fb9100d1d8757c1575b280 AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go tool gqlgen generate
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -ldflags="-s -w" -o storefront-records .

FROM ghcr.io/cujarrett/base-distroless:static-debian13@sha256:76a6ba0713608e3fcca0246b7c1989bbedfcff9809cab66fb6d9388bc091938c
COPY --from=builder /app/storefront-records /storefront-records
# The platform reads the schema from this path in the image and publishes it.
COPY schema.graphql /schema.graphql
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/storefront-records"]
