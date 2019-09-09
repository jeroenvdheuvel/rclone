FROM alpine:3.10

ARG RCLONE_VERSION=1.49.2
ARG GPG_KEYS="93935E02FF3B54FA"

RUN set -xe; \
    apk add --no-cache --update --virtual .runtime-dependencies fuse ca-certificates; \
    echo "user_allow_other" > /etc/fuse.conf; \
    \
    apk add --no-cache --update --virtual .build-dependencies gnupg; \
    \
    wget https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/SHA256SUMS; \
    wget https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip; \
	\
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $GPG_KEYS from $server"; \
		gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
	done; \
    \
    gpg --batch --verify SHA256SUMS; \
    gpg --batch --decrypt SHA256SUMS | grep rclone-v${RCLONE_VERSION}-linux-amd64.zip | sha256sum -c -; \
    \
    unzip rclone-v${RCLONE_VERSION}-linux-amd64.zip; \
    mv rclone-v${RCLONE_VERSION}-linux-amd64/rclone /usr/local/bin/; \
    rm -r rclone-v${RCLONE_VERSION}-linux-amd64*; \
    rm SHA256SUMS; \
    apk del .build-dependencies; \
    rm -r /root/.gnupg;

