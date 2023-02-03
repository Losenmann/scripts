FROM alt:latest

ARG DB_VERSION
ARG DB_ADMIN
ARG DB_PASSWORD

ENV LANG=en_US.utf8
ENV PGVERSION=${DB_VERSION}
ENV PGDATA=/var/lib/pgpro/${DB_VERSION}/data/
ENV PGOPTIONSSRV="-c listen_addresses=*"

RUN echo 'addhba () { echo "host	all		all		$1		md5" >> /var/lib/pgpro/$PGVERSION/data/pg_hba.conf; }' >> /root/.bashrc \
    && source /root/.bashrc \
    && apt-get update && apt-get install -y wget tzdata\
    && wget -O - "https://repo.postgrespro.ru/${DB_VERSION}/keys/pgpro-repo-add.sh" |bash \
    && apt-get install -y postgrespro-${DB_VERSION} \
    && su postgres -c "psql -c \"CREATE ROLE ${DB_ADMIN} WITH CREATEDB CREATEROLE LOGIN SUPERUSER REPLICATION BYPASSRLS PASSWORD '${DB_PASSWORD}';\" 2> /dev/null"

VOLUME /var/lib/pgpro

EXPOSE 5432/tcp

STOPSIGNAL SIGINT

ENTRYPOINT su postgres -c "postgres $PGOPTIONSSRV"
