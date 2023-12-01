FROM curlimages/curl:latest as downloader

RUN curl -sL https://github.com/defenseunicorns/zarf/releases/download/v0.31.3/zarf_v0.31.3_Linux_amd64 -o /tmp/zarf

FROM cgr.dev/chainguard/bash:latest

COPY --from=downloader /tmp/zarf /usr/local/bin/zarf

RUN chmod +x /usr/local/bin/zarf

CMD ["zarf version"]