FROM python:3.10.8-slim

ARG CPU_ARCH=amd64
ARG OAUTH2_PROXY_VERSION=7.4.0



WORKDIR /app

RUN set -x && \
    apt-get -y install wget gnupg && \
    apt-get update && \
    wget https://nginx.org/keys/nginx_signing.key && \
    cat nginx_signing.key | apt-key add - && \
    apt-get -qq update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
    supervisor nginx

# Python deps
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt --no-cache-dir --timeout 1000

# install oauth2-proxy
RUN wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v${OAUTH2_PROXY_VERSION}/oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-${CPU_ARCH}.tar.gz && \
    tar xf oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-${CPU_ARCH}.tar.gz -C /usr/local/bin/ --strip-components 1 && \
    rm oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-${CPU_ARCH}.tar.gz


# set conf files
COPY config/oauth2proxy/oauth2proxy.conf /etc/oauth2proxy.conf
COPY config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf


# Make scripts executable 
COPY scripts /app/scripts
RUN chmod +x /app/scripts/oauth2_proxy.sh && \
    chmod +x /app/scripts/nginx.sh

# WWW (nginx)
RUN addgroup -gid 1000 www && \
    adduser -uid 1000 -H -D -s /bin/sh -G www www

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]