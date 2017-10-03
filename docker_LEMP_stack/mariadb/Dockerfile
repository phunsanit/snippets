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
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

LABEL "application_alias" $APPLICATION_ALIAS
LABEL "genrator" "getcrud.com"

RUN echo -e 'FROM mariadb'

# TimeZone
#RUN cp /usr/share/zoneinfo/Asia/Bangkok /etc/localtime \
#&& echo "Asia/Bangkok" >  /etc/timezone

#Run as user mysql
USER mysql
# start mysql
# CMD ['mysqld']

#RUN mysql -u root -p$MYSQL_ROOT_PASSWORD  -e "GRANT ALL PRIVILEGES ON *.* TO 'comeon'@'%' IDENTIFIED BY 'password';FLUSH PRIVILEGES;"

# prepare sql
#RUN echo -e 'IMPORT prepare.sql'
#ADD prepare.sql /tmp/prepare.sql
#RUN mysql -u root -p$MYSQL_ROOT_PASSWORD  -e "GRANT ALL PRIVILEGES ON *.* TO 'comeon'@'%' IDENTIFIED BY 'password';FLUSH PRIVILEGES;"
#RUN /etc/init.d/mysql -u root -p${MYSQL_ROOT_PASSWORD}  < /tmp/prepare.sql
#RUN sed -i 's/MYSQL_DATABASE/'$MYSQL_DATABASE'/g' /tmp/prepare.sql
#RUN cp /tmp/prepare.sql /docker-entrypoint-initdb.d
#RUN del /tmp/prepare.sql