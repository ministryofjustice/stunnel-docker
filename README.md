# stunnel Docker container

This container uses confd to read environment variables and render the stunnel config file.

## Caveats

This container only allows a single SSL certificate that is shared across all services. If you want an SSL cert per stunnel container this is not for you.

## Build the container

```
docker build --pull -t our.registry-url:platforms/stunnel:1 .
docker push our.registry-url:platforms/stunnel:1
```

## Running Stunnel

Stunnel can authenticate using either pre-shared keys (PSK) or ssl certificates.
Only one should be enabled at a time, otherwise certificate validation will take precedence.
See [https://www.stunnel.org/auth.html](https://www.stunnel.org/auth.html)

### Using PSK authentication

Keys are passed in using the environment variables `STUNNEL_PSK_*`. For example, the following will set three PSK keys,

```
docker run \
    -e STUNNEL_PSK_1={"one": "ilWilpyeuFroajpanbenkyeo"} \
    -e STUNNEL_PSK_2={"two": "PlorrekCiphNoheHyecJejLu"} \
    -e STUNNEL_PSK_3={"three": "shmooshuckWejIrEticyoams"} \
    stunnel
```

generating a psk.txt file for stunnel of,

```
one:ilWilpyeuFroajpanbenkyeo
two:PlorrekCiphNoheHyecJejLu
three:shmooshuckWejIrEticyoams
```

### Using SSL authentication

To use SSL authentication we format the certificate info in a json document with keys of `cert`, `key`, and `chain`. 
This simple snippet will do that for you. (You'll need to create the refered to PEM files.)

```
export STUNNEL_SSL="$(echo '{}' | jq -c \
  --arg cert "$(cat client1.pem)" \
  --arg key "$(cat client1-key.pem)" \
  --arg chain "$(cat ../mojdigital-ca/{intermediate,root}_ca/ca.pem)"
  '.cert = $cert | .chain = $chain | .key = $key')"
```

And then run the container passing that environment variable we just created on the command line or through an env file.

```
docker run --rm -ti \
  --env-file env.example -e "STUNNEL_SSL=$STUNNEL_SSL" \
  --expose 6379  ministryofjustice/stunnel
```

## To configure

Set an environment variable for each service you want stunnel to listen on
prefixed with `STUNNEL_SERVICE_` - for example `STUNNEL_SERVICE_LOGSTASH` or
`STUNNEL_SERVICE_HTTPS`.  The value for each of these should be a JSON object
that defines the config section for the service.

For example (line wrapped for **display only**. This should be on one line when you use it)

```
STUNNEL_SERVICE_LOGSTASH={
  "accept": 6739,
  "connect": 1234,
  "verify": 2}
```

Would render this config file:

```
...

[logstash]

accept=6739
connect=1234
verify=2
```

Read the [stunnel docs][stunnel_docs] for the possible config keys. A quick run down the options we are likely to change:

- `accept`: ("[\<host>:]\<port>") Listen for connection on this local port.
- `connect`: ("[\<host>:]\<port>") And send it to here. If we are a server, this is in the clear; if a client then this is another stunnel instance.
- `client`: ("yes" or "no". Default "no") Make this service act as a client and accept clear and forward to another stunnel server

[stunnel_docs]: https://www.stunnel.org/static/stunnel.html#SERVICE-LEVEL-OPTIONS
