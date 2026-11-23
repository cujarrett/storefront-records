FROM --platform=$BUILDPLATFORM golang:1.27-alpine@sha256:70bd7ddea8b6cbe5d6943cde279d6b67feb10cc924fb9100d1d8757c1575b280 AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go tool gqlgen generate
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -ldflags="-s -w" -o storefront-records .

FROM ghcr.io/cujarrett/base-distroless:static-debian13@sha256:723f8ed3b1060cf54014601bbb883e79f184bb949dcf85e19b209a69d6979ed9
COPY --from=builder /app/storefront-records /storefront-records
# The platform reads the schema from this path in the image and publishes it.
COPY schema.graphql /schema.graphql
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/storefront-records"]
