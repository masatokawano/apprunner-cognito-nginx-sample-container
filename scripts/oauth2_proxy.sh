#!/bin/bash
echo "Starting oauth2 proxy"

exec /usr/local/bin/oauth2-proxy --config /etc/oauth2proxy.conf 