# JMeter on OpenShift

# Version

Tested with JMeter 5.5

# Usage

docker build -t jmeter . --no-cache

docker run -it jmeter /bin/sh

# TO BE VERIFIED
LOCAL_PLUGINS_FOLDER="plugins"
JMETER_CUSTOM_PLUGINS_FOLDER="/plugins"

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

docker run --name ${NAME} -i --mount source=${LOCAL_PLUGINS_FOLDER},destination=${JMETER_CUSTOM_PLUGINS_FOLDER} jmeter


# DONE

- Check args JMeter OK
- User 1001 OK
- Review package installation (wget necessary? nss?) OK
- Metadata OK
- Plugins manager installation OK

# DOING



# TO DO

- Provide input
- Add CMD to provide args on container startup
- Output
- Custom plugins
- JSON logs?
