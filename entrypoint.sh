#!/bin/sh

echo "Configuring remote host..."

echo $REMOTE_HOST
echo $REMOTE_PORT
echo $CONTEXT

echo $GITHUB_REPO

wget $GITHUB_REPO -O test.zip

unzip test.zip

# TODO: change root directory name
dir=$(find ./ -type d -name "example")

echo $dir

rm -rf test.zip

echo "JMeter is starting..."

## Install jmeter add-plugins available on /add-plugins volume
if [ -d $JMETER_CUSTOM_PLUGINS_FOLDER ]
then
    echo "Adding plugins..."
    for plugin in ${JMETER_CUSTOM_PLUGINS_FOLDER}/*.jar; do
        cp $plugin ${JMETER_HOME}/lib/ext
        echo $plugin + " copied."
    done;
fi

# Execute JMeter command
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

mkdir outputs

echo "jmeter -n -q ${dir}/jmeter.properties -t ${dir}/test-plans/USE_CASE_ID.jmx -l outputs/pipeline-results.jtl"

jmeter -n -q ${dir}/jmeter.properties -t ${dir}/test-plans/USE_CASE_ID.jmx -l outputs/pipeline-results.jtl

echo "java -jar ${JMETER_HOME}/lib/cmdrunner-2.3.jar --tool Reporter --generate-csv outputs/aggregate-report.csv --input-jtl outputs/pipeline-results.jtl --plugin-type AggregateReport"

java -jar ${JMETER_HOME}/lib/cmdrunner-2.3.jar --tool Reporter --generate-csv outputs/aggregate-report.csv --input-jtl outputs/pipeline-results.jtl --plugin-type AggregateReport

echo "END Running Jmeter on `date`"

cat outputs/aggregate-report.csv

#
##     -n \
##    -t "/tests/${TEST_DIR}/${TEST_PLAN}.jmx" \
##    -l "/tests/${TEST_DIR}/${TEST_PLAN}.jtl"
## exec tail -f jmeter.log
##    -D "java.rmi.server.hostname=${IP}" \
##    -D "client.rmi.localport=${RMI_PORT}" \
##  -R $REMOTE_HOSTS

sleep 2000

#exit 0
