FROM python:3.10.8-slim

ARG CPU_ARCH=amd64
ARG OAUTH2_PROXY_VERSION=7.4.0

WORKDIR /app

RUN set -x && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
    supervisor wget nginx

# install oauth2-proxy
RUN wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v${OAUTH2_PROXY_VERSION}/oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-${CPU_ARCH}.tar.gz && \
    tar xf oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-${CPU_ARCH}.tar.gz -C /usr/local/bin/ --strip-components 1 && \
    rm oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-${CPU_ARCH}.tar.gz

# set conf files
COPY config/oauth2proxy.conf /etc/oauth2proxy.conf
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/nginx.conf /etc/nginx/nginx.conf


# Make scripts executable 
COPY scripts /app/scripts
RUN chmod +x /app/scripts/oauth2_proxy.sh && \
    chmod +x /app/scripts/nginx.sh

# WWW (nginx)
RUN addgroup -gid 1000 www && \
    adduser -uid 1000 -H -D -s /bin/sh -G www www

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]