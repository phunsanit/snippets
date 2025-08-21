FROM mariadb
MAINTAINER Docker Generator by pitt phunsanit <phunsanit@gmail.com>

ARG APPLICATION_ALIAS
ARG MYSQL_DATABASE
ARG MYSQL_PASSWORD
ARG MYSQL_ROOT_PASSWORD
ARG MYSQL_USER

ENV APPLICATION_ALIAS=$APPLICATION_ALIAS
ENV MYSQL_DATABASE=$MYSQL_DATABASE
ENV MYSQL_PASSWORD=$MYSQL_PASSWORD
ENV MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
ENV MYSQL_USER=$MYSQL_USER

# fixed /bin/sh: 1: [mysql]: not found
ENV PATH=$PATH

LABEL "application_alias" $APPLICATION_ALIAS
LABEL "genrator" "getcrud.com"

#RUN echo -e 'FROM mariadb'

# TimeZone
#RUN cp /usr/share/zoneinfo/Asia/Bangkok /etc/localtime \
#&& echo "Asia/Bangkok" >  /etc/timezone

#Run as user mysql
# USER mysql
# start mysql
# CMD ['mysqld']

#RUN chmod -R 777 /var/lib/mysql

# prepare sql
#RUN echo -e 'IMPORT prepare.sql'

#ADD dataInit/prepare.sql /tmp/prepare.sql

#RUN /bin/bash -c "/usr/bin/mysqld_safe --skip-grant-tables &" && \
#  sleep 5 && \
#  mysql -u root -e "CREATE DATABASE mydb" && \
#  mysql -u root mydb < /tmp/prepare.sql

#RUN rm /tmp/prepare.sql
