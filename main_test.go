package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/handler/transport"

	"github.com/cujarrett/storefront-records/graph"
)

// query runs one operation through the real schema, the way the router does.
func query(t *testing.T, q string) map[string]any {
	t.Helper()
	gql := handler.New(graph.NewExecutableSchema(graph.Config{Resolvers: &graph.Resolver{}}))
	gql.AddTransport(transport.POST{})
	body, _ := json.Marshal(map[string]string{"query": q})
	req := httptest.NewRequest(http.MethodPost, "/graphql", strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	gql.ServeHTTP(rec, req)
	var out struct {
		Data   map[string]any `json:"data"`
		Errors []any          `json:"errors"`
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &out); err != nil {
		t.Fatalf("decode %s: %v", rec.Body.String(), err)
	}
	if len(out.Errors) > 0 {
		t.Fatalf("errors: %v", out.Errors)
	}
	return out.Data
}

func TestListsAllRecords(t *testing.T) {
	data := query(t, `{ records { id title year } }`)
	records := data["records"].([]any)
	if len(records) != 2 {
		t.Fatalf("got %d records, want 2", len(records))
	}
	first := records[0].(map[string]any)
	if first["year"] != float64(1959) {
		t.Errorf("year = %v, want 1959", first["year"])
	}
}

func TestResolvesAReferenceByID(t *testing.T) {
	data := query(t, `{ _entities(representations: [{__typename: "Record", id: "1"}, {__typename: "Record", id: "missing"}]) { ... on Record { title } } }`)
	entities := data["_entities"].([]any)
	if got := entities[0].(map[string]any)["title"]; got != "Kind of Blue" {
		t.Errorf("title = %v, want Kind of Blue", got)
	}
	if entities[1] != nil {
		t.Errorf("unknown id = %v, want null", entities[1])
	}
}
