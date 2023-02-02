FROM alt:latest

ARG vers
ARG PGADMIN
ARG PGPASSWORD

ENV LANG=en_US.utf8
ENV VERSION=$vers
ENV PGDATA=/var/lib/pgpro/$vers/data/
ENV PGOPTIONSSRV="-c listen_addresses=*"

RUN echo 'addhba () { echo "host	all		all		$1		md5" >> /var/lib/pgpro/$VERSION/data/pg_hba.conf; }' >> /root/.bashrc \
    && source /root/.bashrc \
		&& apt-get update && apt-get install -y wget tzdata\
    && wget -O - "https://repo.postgrespro.ru/$vers/keys/pgpro-repo-add.sh" |bash \
    && apt-get install -y postgrespro-$vers \
		&& su postgres -c "psql -c \"CREATE ROLE $PGADMIN WITH CREATEDB CREATEROLE LOGIN SUPERUSER REPLICATION BYPASSRLS PASSWORD '$PGPASSWORD';\""

VOLUME /var/lib/pgpro

EXPOSE 5432/tcp

STOPSIGNAL SIGINT

ENTRYPOINT su postgres -c "postgres $PGOPTIONSSRV"
