FROM golang:alpine AS builder

ENV VERSION=v1.7

RUN apk add --no-cache git \
    && git clone --depth 1 --branch ${VERSION} https://github.com/shawn1m/overture.git /build \
    && cd /build \
    && go build -o overture main/main.go

FROM alpine:latest
LABEL authors "jasperhale <ljy087621@gmail.com>"

ENV OVERTURE_HOME="/home/overture"
ENV DATA_DIR="${OVERTURE_HOME}/data"
ENV TMP_DIR="${OVERTURE_HOME}/tmp"

RUN echo "export DATA_DIR=${DATA_DIR}" >> /etc/profile  \
    && echo "export OVERTURE_HOME=${OVERTURE_HOME}" >> /etc/profile

COPY ./shell/getfilter.sh /getfilter.sh

RUN set -xe  \
    && apk add --no-cache curl ca-certificates \
    && mkdir -p "$OVERTURE_HOME" "$DATA_DIR" \
    && chmod a+x /getfilter.sh  \
    && sh /getfilter.sh

COPY --from=builder /build/overture "$OVERTURE_HOME/overture"
COPY config.yml "$OVERTURE_HOME/config.yml"
COPY ./shell/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh "$OVERTURE_HOME/overture"

EXPOSE 53/tcp
EXPOSE 53/udp

VOLUME "$DATA_DIR"

ENTRYPOINT [ "/entrypoint.sh" ]
