FROM alpine:latest

RUN apk add --no-cache \
        git \
        git-lfs \
 && rm -rf /var/cache/apk/*

COPY . .
