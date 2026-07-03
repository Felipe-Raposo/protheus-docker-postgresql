FROM postgres:16
LABEL maintainer="Felipe Raposo <feliperaposo@gmail.com>"
EXPOSE 5432/tcp
ENV LANG=pt_BR.CP1252
RUN localedef -i pt_BR -c -f CP1252 -A /usr/share/locale/locale.alias pt_BR.CP1252
COPY ./root/ /
RUN chmod +x /usr/local/bin/protheus-entrypoint.sh \
             /usr/local/bin/protheus-reconcile.sh \
             /docker-entrypoint-initdb.d/postgres_protheus.sh
ENTRYPOINT ["protheus-entrypoint.sh"]
CMD ["postgres", "-c", "config_file=/etc/postgresql.conf"]
