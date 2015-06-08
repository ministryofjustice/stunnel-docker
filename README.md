# stunnel Docker container

This container uses confd to read environment variables and render the stunnel config file.

## Build the container

```
docker build -t our.registry-url:platforms/stunnel:1 .
docker push our.registry-url:platforms/stunnel:1
```

## To Run

You'll need to create the refered to PEM files.

```
docker run --rm -ti \
  --env-file env.example \
  -v stunnel1.pem:/tmp/cert.pem \
  -v stunnel1-key.pem:/tmp/key.pem \
  -v ca-chain.pem:/tmp/ca-chain.pem \
  --expose 6379  ministryofjustice/stunnel
```

## To configure

Set an environment variable for each service you want stunnel to listen on
prefixed with `STUNNEL_` - for example `STUNNEL_LOGSTASH` or `STUNNEL_HTTPS`.
The value for each of these should be a JSON object that defines the config
section for the service.

For example

```
STUNNEL_LOGSTASH={"accept": 6739, "connect": 1234, "verify": 2, "cert":"/tmp/cert.pem", "key":"/tmp/key.pem", "CAfile": "/tmp/ca-chain.pem"}
```

Would render this config file:

```
...

[logstash]

CAfile=/tmp/ca-chain.pem
accept=6739
cert=/tmp/cert.pem
connect=1234
key=/tmp/key.pem
verify=2
```

Read the [stunnel docs][stunnel_docs] for the possible config keys

[stunnel_docs]: https://www.stunnel.org/static/stunnel.html#SERVICE-LEVEL-OPTIONS
