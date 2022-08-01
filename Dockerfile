# Author: Marcello.DeSales@gmail.com
FROM ubuntu

WORKDIR /app

# Set up in Los Angeles
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive/67734239#67734239
RUN echo 'tzdata tzdata/Areas select America' | debconf-set-selections && \
    echo 'tzdata tzdata/Zones/America select Los_Angeles' | debconf-set-selections
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata

# Install CDK and Frontend
RUN apt-get update && apt-get install -y \
    make \
    software-properties-common npm \
    && npm install -g aws-cdk ts-node

# Install deps for SAM Backend
# https://stackoverflow.com/questions/65644782/how-to-install-pip-for-python-3-9-on-ubuntu-20-04/70681853#70681853
ENV PYTHON_VERSION_SHORT=3.9
RUN apt-get install -y python${PYTHON_VERSION_SHORT} python3-pip && \
       ln -s -f /usr/bin/python${PYTHON_VERSION_SHORT} /usr/bin/python3 && \
       ln -s -f /usr/bin/python${PYTHON_VERSION_SHORT} /usr/bin/python && \
       ln -s -f /usr/bin/pip3 /usr/bin/pip

# Install SAM itself
RUN apt-get install -y python3.8-venv python3.9-venv \
    && pip install awscli aws-sam-cli==1.53.0 \
    && rm -rf /var/lib/apt/lists/*

# Fix error for newer versions of sam
# https://stackoverflow.com/questions/71718167/importerror-cannot-import-name-escape-from-jinja2/72653770#72653770
RUN pip uninstall -y flask && \
    pip install flask

# SAM failing during bootstrap with 
# parkinglot-service-serverless-cdk-sam-1  |     service.run()
#parkinglot-service-serverless-cdk-sam-1  |   File "/usr/local/lib/python3.9/dist-packages/flask/app.py", line 914, in run
# parkinglot-service-serverless-cdk-sam-1  |     run_simple(t.cast(str, host), port, self, **options)
#parkinglot-service-serverless-cdk-sam-1  |   File "/usr/local/lib/python3.9/dist-packages/werkzeug/serving.py", line 1063, in run_simple
#parkinglot-service-serverless-cdk-sam-1  |     fd = int(os.environ["WERKZEUG_SERVER_FD"])
#parkinglot-service-serverless-cdk-sam-1  | ValueError: invalid literal for int() with base 10: 'false'
# Fixed by https://github.com/cs01/gdbgui/issues/425#issuecomment-1144565569
# https://github.com/cs01/gdbgui/issues/425#issuecomment-1200916195
RUN pip install gdbgui && \
    pip install werkzeug==2.0.0

# Install docker as it is required to run containers
# https://devopscube.com/run-docker-in-docker/
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy curl && \
    apt-get install -qy curl && \
    curl -sSL https://get.docker.com/ | sh

# Just show the current version
# Could only run SAM after setting internal container host
# https://github.com/aws/aws-sam-cli/issues/2436#issuecomment-1200922963
# User provide the docker network desired as env var as it is created and defined by the user
ENTRYPOINT ["sam", "local", "start-api", "-p", "3000", "--host", "0.0.0.0", "--docker-network", "aws_backend", "--container-host", "host.docker.internal"]
