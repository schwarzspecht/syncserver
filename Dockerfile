FROM arm32v7/python:2.7-slim

RUN groupadd --gid 1001 app && \
    useradd --uid 1001 --gid 1001 --shell /usr/sbin/nologin app

ENV LANG C.UTF-8

WORKDIR /app

# S3 bucket in Cloud Services prod IAM
ADD  http://ftp.us.debian.org/debian/pool/main/d/dumb-init/dumb-init_1.2.0-1_armhf.deb /tmp/dumb-init_1.2.0-1_armhf.deb 
RUN dpkg -x /tmp/dumb-init_1.2.0-1_armhf.deb /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# install syncserver dependencies
COPY ./requirements.txt /app/requirements.txt
COPY ./dev-requirements.txt /app/dev-requirements.txt
RUN apt-get -q update \
    && apt-get -q --yes install g++ \
    && pip install --upgrade --no-cache-dir -r requirements.txt \
    && pip install --upgrade --no-cache-dir -r dev-requirements.txt \
    && apt-get -q --yes remove g++ \
    && apt-get -q --yes autoremove \
    && apt-get clean

COPY ./syncserver /app/syncserver
COPY ./setup.py /app
#RUN python ./setup.py develop

# run as non priviledged user
USER app
