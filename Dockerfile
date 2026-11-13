FROM --platform=$BUILDPLATFORM golang:1.27-alpine@sha256:d200d2dd76b03a99b52651fd1325aff7dcd35422c35c01bac56571b0507f3deb AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go tool gqlgen generate
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -ldflags="-s -w" -o storefront-records .

FROM ghcr.io/cujarrett/base-go:static-debian13@sha256:f0505a0e3fdd29902098d6ef26b5dc5bd206841aa33441bb875b5ccdc117cfe0
COPY --from=builder /app/storefront-records /storefront-records
# The platform reads the schema from this path in the image and publishes it.
COPY schema.graphql /schema.graphql
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/storefront-records"]
