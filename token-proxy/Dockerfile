# --- build stage ---
FROM golang:1.26-alpine AS build
WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/dj-token-proxy .

# --- runtime stage ---
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/dj-token-proxy /dj-token-proxy
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/dj-token-proxy"]
