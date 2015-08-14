FROM debian:jessie

WORKDIR /

ENV stunnel_version 5.22

# The packaged version of stunnel isn't recent enough for our tastes, so lets
# build it ourselves and remove the dev packages once we are done
RUN apt-get update && \
  apt-get install -y build-essential curl libssl-dev && \
  mkdir -p /tmp/stunnel/ && cd /tmp/stunnel && \
  curl https://www.usenix.org.uk/mirrors/stunnel/archive/5.x/stunnel-${stunnel_version}.tar.gz | tar --strip 1 -zx && \
  ./configure && \
  make install && \
  cd / && \
  rm -rf /tmp/stunnel && \
  apt-get -y autoremove build-essential libssl-dev

# Copy in confd templates and config files
COPY confd /etc/confd
COPY run.sh $WORKDIR

RUN adduser stunnel --home /home/stunnel --shell /bin/bash --disabled-password --gecos ""

# Since "ADD" with a URL invalidates the cache always put it at the end
ADD https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64 /usr/local/bin/confd

RUN chmod +x /usr/local/bin/confd

USER stunnel

CMD ["./run.sh"]
