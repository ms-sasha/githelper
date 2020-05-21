FROM alpine:latest

ARG GIT_PROVIDER=""

ENV ROOT_DIRECTORY=/srv

RUN apk add --no-cache \
        git \
        git-lfs \
        jq \
        openssh-client \
 && rm -rf /var/cache/apk/* \
 && mkdir -p "${ROOT_DIRECTORY}"

COPY /root /

WORKDIR $ROOT_DIRECTORY

ENTRYPOINT ["githelper.sh"]
