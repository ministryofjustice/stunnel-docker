FROM debian:jessie

WORKDIR /

ENV stunnel_version 5.17

# The packaged version of stunnel isn't recent enough for our tastes, so lets
# build it ourselves and remove the dev packages once we are done
RUN apt-get update && \
  apt-get install -y build-essential curl libssl-dev && \
  mkdir -p /tmp/stunnel/ && cd /tmp/stunnel && \
  curl https://www.stunnel.org/downloads/stunnel-${stunnel_version}.tar.gz | tar --strip 1 -zx && \
  ./configure && \
  make install && \
  cd / && \
  rm -rf /tmp/stunnel && \
  apt-get -y autoremove build-essential libssl-dev

COPY stunnel.toml /etc/confd/conf.d/
COPY stunnel.cnf.tmpl /etc/confd/templates/
COPY run.sh $WORKDIR

# Since "ADD" with a URL invalidates the cache always put it at the end
ADD https://github.com/kelseyhightower/confd/releases/download/v0.9.0/confd-0.9.0-linux-amd64 /usr/local/bin/confd

RUN chmod +x /usr/local/bin/confd

CMD ["./run.sh"]
