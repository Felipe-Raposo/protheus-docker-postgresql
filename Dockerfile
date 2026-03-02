FROM postgres:16
LABEL maintainer="Felipe Raposo <feliperaposo@gmail.com>"
EXPOSE 5432/tcp
ENV CONFIG_FILE=/etc/postgresql.conf
ENV LANG=pt_BR.CP1252
RUN localedef -i pt_BR -c -f CP1252 -A /usr/share/locale/locale.alias pt_BR.CP1252
COPY ./root/ /
