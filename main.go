package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/handler/transport"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"github.com/cujarrett/storefront-records/graph"
)

func main() {
	port := envOr("PORT", "4001")
	metricsPort := envOr("METRICS_PORT", "9090")
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))

	gql := handler.New(graph.NewExecutableSchema(graph.Config{Resolvers: &graph.Resolver{}}))
	gql.AddTransport(transport.POST{})

	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.Write([]byte("ok")) //nolint:errcheck
	})
	mux.Handle("/graphql", gql)
	srv := &http.Server{Addr: ":" + port, Handler: mux}

	// Metrics on their own port. The platform scrapes it without mTLS,
	// so it must never share a port with GraphQL.
	metricsMux := http.NewServeMux()
	metricsMux.Handle("GET /metrics", promhttp.Handler())
	metrics := &http.Server{Addr: ":" + metricsPort, Handler: metricsMux}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	for _, s := range []*http.Server{srv, metrics} {
		go func() {
			if err := s.ListenAndServe(); err != nil && err != http.ErrServerClosed {
				logger.Error("server error", "addr", s.Addr, "err", err)
				os.Exit(1)
			}
		}()
	}
	logger.Info("records subgraph listening", "url", "http://localhost:"+port+"/graphql")

	<-ctx.Done()
	logger.Info("shutting down")
	for _, s := range []*http.Server{srv, metrics} {
		if err := s.Shutdown(context.Background()); err != nil {
			logger.Error("shutdown error", "addr", s.Addr, "err", err)
		}
	}
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
