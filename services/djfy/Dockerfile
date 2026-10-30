FROM golang:1.26-alpine AS build
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /djfy .

FROM gcr.io/distroless/static-debian12
COPY --from=build /djfy /djfy
ENV DJFY_ADDR=:8097
EXPOSE 8097
ENTRYPOINT ["/djfy"]
