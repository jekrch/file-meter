FROM alpine:latest

RUN apk add --no-cache bash findutils coreutils parallel pv ncurses

COPY file_size_analyzer.sh /app/file_size_analyzer.sh
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/file_size_analyzer.sh /app/entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]