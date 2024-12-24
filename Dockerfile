FROM ghcr.io/gleam-lang/gleam:v1.6.3-erlang-slim AS build
WORKDIR /app

COPY gleam.toml manifest.toml .
RUN gleam update

COPY ./src/ ./src/
RUN gleam export erlang-shipment

FROM ghcr.io/gleam-lang/gleam:v1.6.3-erlang-slim AS final
WORKDIR /app
COPY --from=build /app/build/erlang-shipment .

EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
