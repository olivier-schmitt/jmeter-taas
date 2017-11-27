FROM ubuntu:16.04
MAINTAINER www.olivierschmitt.me

LABEL "com.jeecookbook.taas.jmeter.version"="3.3"
LABEL "com.jeecookbook.taas.jmeter.flavor"="Ubuntu LTS"
LABEL "authors"="www.olivierschmitt.me"

RUN apt-get update
RUN apt-get install -y lsof
RUN apt-get install -y apache2 apache2-utils
RUN apt-get install -y openjdk-8-jdk
RUN rm -rf /var/lib/apt/lists/*

ENV JMETER_HOME /usr/local/apache-jmeter
ENV JMETER_BIN $JMETER_HOME/bin
ENV TAAS_RMI_SERVER_HOSTNAME 127.0.0.1
ENV TAAS_CLIENT_RMI_PORT 1099
ENV TAAS_SERVER_RMI_PORT 1100

ENV PATH $PATH:$JMETER_BIN

COPY src/main/resources/apache-jmeter-3.3 $JMETER_HOME

RUN a2enmod dav dav_fs && a2dissite 000-default

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_RUN_DIR /var/run/apache2

RUN mkdir -p /var/lock/apache2; chown www-data /var/lock/apache2 && mkdir -p /var/webdav; chown www-data /var/webdav
RUN chown -R root:www-data /usr/local/apache-jmeter

COPY src/main/resources/webdav.conf /etc/apache2/sites-available/webdav.conf

RUN a2ensite webdav

# Share the volume with the files to other dockers
VOLUME  $JMETER_HOME

WORKDIR $JMETER_HOME

COPY src/main/resources/entrypoint.sh /

RUN chmod +x /entrypoint.sh

EXPOSE 80 $TAAS_CLIENT_RMI_PORT $TAAS_SERVER_RMI_PORT

ENTRYPOINT ["/entrypoint.sh"]