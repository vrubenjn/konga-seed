#!/bin/sh

export KONGA_DEFAULT_KONG_NODE=$KONGA_DEFAULT_KONG_PROTOCOL://$KONGA_DEFAULT_KONG_HOST:$KONGA_DEFAULT_KONG_PORT

if [ ! -f /tmp/first_run ]; then
    while ! pg_isready -h ${DB_HOST} -p ${DB_PORT} > /dev/null 2> /dev/null; do
        echo "Waiting for database ${DB_HOST}:${DB_PORT}"
        sleep 2
    done

    sed 's/$KONGA_DEFAULT_EMAIL/'"${KONGA_DEFAULT_EMAIL}"'/g' /seed/user.seed > /tmp/user.seed
    mv -f /tmp/user.seed /seed/user.seed
    sed 's/$KONGA_DEFAULT_PASSWORD/'"${KONGA_DEFAULT_PASSWORD}"'/g' /seed/user.seed > /tmp/user.seed
    mv -f /tmp/user.seed /seed/user.seed

    sed 's@$KONGA_DEFAULT_KONG_NODE@'"${KONGA_DEFAULT_KONG_NODE}"'@g' /seed/kong_node.seed > /tmp/kong_node.seed
    mv -f /tmp/kong_node.seed /seed/kong_node.seed

    /app/start.sh -c prepare -a ${DB_ADAPTER} -u ${DB_PROTOCOL}://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_DATABASE}?currentSchema=${DB_PG_SCHEMA}

    echo ${DB_HOST}:${DB_PORT}:${DB_DATABASE}:${DB_USER}:${DB_PASSWORD} > ~/.pgpass
    chmod 600 ~/.pgpass
    psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_DATABASE} -w -c "UPDATE ${DB_PG_SCHEMA}.konga_users SET node=1;"

    /wait-for-it.sh -h $KONGA_DEFAULT_KONG_HOST -p $KONGA_DEFAULT_KONG_PORT -t 60

    if [ -f "/setup/setup.sh" ]
    then
        chmod +x /setup/setup.sh
        /setup/setup.sh
    fi

    touch /tmp/first_run
fi

/app/start.sh $@
