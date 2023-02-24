#!/bin/sh

echo "JMeter is starting..."

#ls -la $JMETER_CUSTOM_PLUGINS_FOLDER
#
## Install jmeter plugins available on /plugins volume
#if [ -d $JMETER_CUSTOM_PLUGINS_FOLDER ]
#then
#    echo "Adding plugins..."
#    for plugin in ${JMETER_CUSTOM_PLUGINS_FOLDER}/*.jar; do
#        cp $plugin ${JMETER_HOME}/lib/ext
#        echo $plugin + " copied."
#    done;
#fi

 Execute JMeter command
set -e
freeMem=`awk '/MemAvailable/ { print int($2/1024) }' /proc/meminfo`

[[ -z ${JVM_XMN} ]] && JVM_XMN=$(($freeMem/10*2))
[[ -z ${JVM_XMS} ]] && JVM_XMS=$(($freeMem/10*8))
[[ -z ${JVM_XMX} ]] && JVM_XMX=$(($freeMem/10*8))

export JVM_ARGS="-Xmn${JVM_XMN}m -Xms${JVM_XMS}m -Xmx${JVM_XMX}m"

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$@"

# Keep entrypoint simple: we must pass the standard JMeter arguments
EXTRA_ARGS=-Dlog4j2.formatMsgNoLookups=true
echo "jmeter ALL ARGS=${EXTRA_ARGS} $@"
#jmeter ${EXTRA_ARGS} $@

echo "END Running Jmeter on `date`"
#
##     -n \
##    -t "/tests/${TEST_DIR}/${TEST_PLAN}.jmx" \
##    -l "/tests/${TEST_DIR}/${TEST_PLAN}.jtl"
## exec tail -f jmeter.log
##    -D "java.rmi.server.hostname=${IP}" \
##    -D "client.rmi.localport=${RMI_PORT}" \
##  -R $REMOTE_HOSTS
