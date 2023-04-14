#!/bin/sh

countdown() {
  n=${1:-10}

  while [ $n -gt 0 ]; do
    printf "\r%s... " $n
    sleep 1
    n=$((n-1))
  done
  printf "\r \r"

  exit 0
}

echo -e "\e[36m#############################\e[0m"
echo -e "\e[36mRetrieve basic information...\e[0m"
echo -e "\e[36m#############################\e[0m"

if [ -n "$REMOTE_PROTOCOL" ]
then
  echo "Remote protocol:" $REMOTE_PROTOCOL
fi

echo "Remote host:" $REMOTE_HOST

if [ -n "$REMOTE_PORT" ]
then
  echo "Remote port:" $REMOTE_PORT
fi

if [ -n "$CONTEXT" ]
then
  echo "Context for web application:" $CONTEXT
fi

echo "GitHub Repo:" $GITHUB_REPO

if [ -n "$GITHUB_BRANCH" ]
then
  echo "GitHub Branch:" $GITHUB_BRANCH
fi

if [ -n "$GITHUB_TOKEN" ]
then
  echo "GitHub Token:" && echo ${GITHUB_TOKEN:0:20}...

fi

echo "Test plans directory:" $TEST_DIR
echo "List of the test plans:" $TEST_LIST


# Download the repository

if [ -z "$GITHUB_TOKEN" ]
then
  echo "Token empty. Repository is supposed to be PUBLIC."
  wget $GITHUB_REPO/zipball/$GITHUB_BRANCH/ -O $GITHUB_BRANCH.zip  || (echo -e "\e[31mRepository not found. Check the previous logs for the details!\e[0m" && countdown 10)
else
  echo "Token not empty. Repository is supposed to be PRIVATE."
  wget --header "Authorization: token $GITHUB_TOKEN" $GITHUB_REPO/zipball/$GITHUB_BRANCH/ -O $GITHUB_BRANCH.zip
fi

unzip $GITHUB_BRANCH.zip || (echo -e "\e[31mUnzip was not possible. Check the previous logs for the details!\e[0m" &&
 countdown 10)

rm -rf $GITHUB_BRANCH.zip

# Find the specified folder
dir=$(find ./ -type d -name "$TEST_DIR")

# Split multiple test to an array
if [ -n "$TEST_LIST" ]
then
  IFS=', ' read -r -a tests_list <<< $TEST_LIST
else
  echo -e "\e[31mEmpty list of test plans. Specified the desidered ones and run again the Pod!\e[0m" && countdown 10
fi

echo -e "\e[36m#############################\e[0m"
echo -e "\e[36mJMeter prep...\e[0m"
echo -e "\e[36m#############################\e[0m"

# Reading and parsing JMeter.properties

PROPS_FILE=$dir"/jmeter.properties"
setProperty(){
  awk -v pat="^$1=" -v value="$1=$2" '{ if ($0 ~ pat) print value; else print $0; }' $3 > $3.tmp
  mv $3.tmp $3
}

### usage: setProperty $key $value $filename
if [ -n "$REMOTE_PROTOCOL" ]
then
  setProperty "protocol"  $REMOTE_PROTOCOL  $PROPS_FILE
fi

setProperty "serverName"  $REMOTE_HOST  $PROPS_FILE

if [ -n "$REMOTE_PORT" ]
then
  setProperty "port"  $REMOTE_PORT  $PROPS_FILE
fi


## Install JMeter add-plugins available on /add-plugins volume
if [ -d $JMETER_CUSTOM_PLUGINS_FOLDER ]
then
    echo "Adding plugins..."
    for plugin in ${JMETER_CUSTOM_PLUGINS_FOLDER}/*.jar; do
        cp $plugin ${JMETER_HOME}/lib/ext
        echo $plugin " copied."
    done;
fi

# Execute JMeter command
set -e
freeMem=`awk '/MemAvailable/ { print int($2/1024) }' /proc/meminfo`

[[ -z ${JVM_XMN} ]] && JVM_XMN=$(($freeMem/10*2))
[[ -z ${JVM_XMS} ]] && JVM_XMS=$(($freeMem/10*8))
[[ -z ${JVM_XMX} ]] && JVM_XMX=$(($freeMem/10*8))

export JVM_ARGS="-Xmn${JVM_XMN}m -Xms${JVM_XMS}m -Xmx${JVM_XMX}m -Djava.util.prefs.userRoot=/tmp/.systemPrefs -Djava.util.prefs.systemRoot=/tmp/.systemPrefs"

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$@"

# Keep entrypoint simple: we must pass the standard JMeter arguments
EXTRA_ARGS=-Dlog4j2.formatMsgNoLookups=true
echo "jmeter ALL ARGS=${EXTRA_ARGS} $@"
#jmeter ${EXTRA_ARGS} $@

mkdir -p outputs logs

for testname in "${tests_list[@]}"; do
  echo -e "\e[36m#############################\e[0m"
  echo -e "\e[36mTest execution\e[0m"
  echo -e "\e[36m#############################\e[0m"

  echo "jmeter -n -q ${dir}/jmeter.properties -t ${dir}/test-plans/${testname}.jmx -l outputs/pipeline-results.jtl"

  {
    jmeter -n -q ${dir}/jmeter.properties -t "${dir}/test-plans/${testname}".jmx -l outputs/${testname}-results.jtl
  } || {
    echo -e "\e[31mSome tests have failed. Check the logs.\e[0m"
    countdown 10
  }

  echo "########## Get outputs"

  echo "java -jar ${JMETER_HOME}/lib/cmdrunner-2.3.jar --tool Reporter --generate-csv logs/${testname}-aggregate-report.csv --input-jtl outputs/${testname}-results.jtl --plugin-type AggregateReport"


  {
    java -jar "${JMETER_HOME}/lib/cmdrunner-2.3.jar" --tool Reporter --generate-csv logs/${testname}-aggregate-report.csv --input-jtl outputs/${testname}-results.jtl --plugin-type AggregateReport
  } || {
    echo -e "\e[31mReports' generation has failed. Check the logs.\e[0m"
    countdown 10
  }

  echo -e "\e[36m#############################\e[0m"
done

echo -e "\e[36m#############################\e[0m"
echo -e "\e[36mEND Running Jmeter on: `date`\e[0m"
echo -e "\e[36m#############################\e[0m"

cat ${dir}/logs/aggregate-report.csv

test_results=$(grep -r '>true<' ${dir}/logs/ | uniq)

if [[ -z ${test_results} ]]; then
  echo -e "\e[92mTest completed successfully!\e[0m"
  countdown 100
else
  echo -e "\e[31mSome tests have failed. Check the logs.\e[0m"
  countdown 10
fi

exit 0
