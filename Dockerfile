FROM pantsel/konga
# Variables
ENV DB_ADAPTER=postgres
ENV DB_PROTOCOL=postgresql
ENV DB_PORT=5432
ENV KONGA_DEFAULT_EMAIL=konga@konga.docker
ENV KONGA_DEFAULT_PASSWORD=password
ENV KONGA_DEFAULT_KONG_PROTOCOL=http
ENV KONGA_DEFAULT_KONG_PORT=8001
ENV KONGA_SEED_USER_DATA_SOURCE_FILE=/seed/user.seed
ENV KONGA_SEED_KONG_NODE_DATA_SOURCE_FILE=/seed/kong_node.seed
# Commands
RUN apk add postgresql-client curl jq
COPY wait-for-it.sh /wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chmod +x /wait-for-it.sh
COPY user.seed /seed/user.seed
COPY kong_node.seed /seed/kong_node.seed
ENTRYPOINT ["/entrypoint.sh"]