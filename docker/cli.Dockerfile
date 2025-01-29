# build stage
# small surface area for cli
FROM rust:1-slim-bullseye as builder

WORKDIR /farseer_cli
COPY ../farseer/cli .

# build app
RUN cargo build --release

# runtime stage
FROM debian:bullseye-slim

# update + install ssl certs, remove package lists
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# copy binary from builder to local runtime
COPY --from=builder /farseer_cli/target/release/farseer /usr/local/bin/

# set binary as entrypoint
ENTRYPOINT ["farseer"]
# default args (can be overridden)
CMD ["--help"]
