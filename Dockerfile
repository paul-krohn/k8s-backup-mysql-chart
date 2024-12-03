FROM alpine:3.20.3

RUN apk add --no-cache mysql-client aws-cli curl bash gzip

ENV TARGET_DATABASE_PORT=3306
ENV NOTIFY_ENABLED=false

COPY scripts/backup.sh /usr/local/bin
RUN chmod +x /usr/local/bin/backup.sh
CMD ["/usr/local/bin/backup.sh"]
