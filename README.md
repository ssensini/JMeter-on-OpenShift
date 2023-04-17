# JMeter on OpenShift

# Description

Custom template to deploy JMeter on OpenShift and perform a load/functional test on an application.

It takes as input some information about the application that should be tested, such as the host, the source code 
repository and the test plans' list, and then performs the tests.

# Version

Tested with JMeter 5.5

# Update image

```
docker build -t 350801433917.dkr.ecr.eu-west-1.amazonaws.com/enterprise-architect/jmeter:0.0.5-SNAPSHOT .
docker push 350801433917.dkr.ecr.eu-west-1.amazonaws.com/enterprise-architect/jmeter:0.0.5-SNAPSHOT
```

# Local usage

```
docker build -t jmeter . --no-cache

# mandatory fields
docker run \
    -e REMOTE_HOST=[MYHOST] \
    -e REMOTE_PORT=[MYPORT] \
    -e GITHUB_REPO=[MYREPO] \
    -e TEST_LIST=[MYUSECASE] \
    jmeter

# not mandatory fields

docker run \
    -e REMOTE_HOST=[MYHOST] \
    -e REMOTE_PORT=[MYPORT] \
    -e REMOTE_PROTOCOL=[HTTP/HTTPS] \
    -e GITHUB_REPO=[MYREPO]   \
    -e GITHUB_BRANCH=[MYBRANCH] \
    -e GITHUB_TOKEN=[MYTOKEN] \
    -e TEST_LIST=[MYUSECASE] \
    -e TEST_DIR=[MYDIR] \
    jmeter 
```

# On OpenShift

Deploy the template called _dedalus.template.yml_.

# DONE

- Check args JMeter OK
- User 1001 OK
- Review package installation (wget necessary? nss?) OK
- Metadata OK
- Plugins manager installation OK
- Provide input OK
- Add CMD to provide args on container startup OK
- Output OK
- Custom plugins OK
- provide a list of tests that should  be run (0.0.3) OK
- append custom properties file OK

# DOING
 
# TO DO

- JSON logs?
