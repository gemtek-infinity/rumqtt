FROM rust:1.64-alpine3.16 as builder

RUN apk add build-base openssl-dev protoc
ARG RUSTFLAGS="-C inline-threshold=256 -C opt-level=3 -C codegen-units=1 -C link-args=-s"
RUN echo ${RUSTFLAGS}
WORKDIR /usr/src/rumqtt
COPY . .
RUN cargo build --release -p rumqttd --features="mimalloc"

FROM alpine:3.16

COPY --from=builder /usr/src/rumqtt/target/release/rumqttd /usr/local/bin/rumqttd
COPY ./rumqttd/demo.toml runconfig.toml
ENV RUST_LOG="info"
ENTRYPOINT ["rumqttd", "--config", "runconfig.toml"]
