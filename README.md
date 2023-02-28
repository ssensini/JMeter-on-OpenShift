# JMeter on OpenShift

# Version

Tested with JMeter 5.5

# Local build

docker build -t 350801433917.dkr.ecr.eu-west-1.amazonaws.com/enterprise-architect/jmeter:0.0.2-SNAPSHOT .
docker push 350801433917.dkr.ecr.eu-west-1.amazonaws.com/enterprise-architect/jmeter:0.0.2-SNAPSHOT

# Local usage

docker build -t jmeter . --no-cache
docker run -it jmeter /bin/sh

# On OpenShift

Deploy the template.

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

# DOING
 

# TO DO

- Remote conf is BUILT-in: where do we take those infos? from environment? do we override the information based in 
  jmeter.properties?
- JSON logs?
