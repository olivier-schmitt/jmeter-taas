#!/bin/bash

rm -f $JMETER_HOME/jmeter-server.log

# Launch SSH Daemon
#/usr/sbin/sshd

# Launch Apache mod dav
htpasswd -c -b /etc/apache2/webdav.password $TAAS_DAV_USERNAME $TAAS_DAV_PASSWORD
chown root:www-data /etc/apache2/webdav.password
chmod 640 /etc/apache2/webdav.password
apache2 -k restart

chown root:www-data $JMETER_HOME

# JMeter section

#export JVM_ARGS="-Xms1024m -Xmx1024m"

export JVM_ARGS="${TAAS_JVM_ARGS} -Djava.net.preferIPv4Stack=${TAAS_JVM_PREFER_IPV4_STACK}"

echo "Debug mode:${TAAS_DEBUG}"

if [ -n "${TAAS_DEBUG}" ]
then
    JVM_ARGS="${JVM_ARGS} -Djava.rmi.server.logCalls=true -Dsun.rmi.server.logLevel=VERBOSE -Dsun.rmi.client.logCalls=true -Dsun.rmi.transport.tcp.logLevel=VERBOSE"
fi

echo "JVM conf ${JVM_ARGS}"
echo "RMI Client Port conf ${TAAS_CLIENT_RMI_PORT}"
echo "RMI Server Port conf ${TAAS_SERVER_RMI_PORT}"

JMETER_LOG="jmeter-server.log" && touch $JMETER_LOG && tail -f $JMETER_LOG &

SERVER_PORT="${TAAS_SERVER_RMI_PORT}"

export SERVER_PORT


if [ -n "${TAAS_USE_TUNNELING}" ]
then
    socat -s -t 1800 TCP-LISTEN:${TAAS_CLIENT_RMI_PORT},fork TCP:172.17.0.1:${TAAS_CLIENT_RMI_PORT} &
fi

exec jmeter-server \
    -Djava.rmi.server.hostname="${TAAS_RMI_SERVER_HOSTNAME}" \
    -Dclient.rmi.localport="${TAAS_CLIENT_RMI_PORT}" \
    -Dserver.rmi.localport="${TAAS_SERVER_RMI_PORT}"
