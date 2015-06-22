# Changelog for stunnel container

## v3 (unreleased)

* Change prefix for configuring services from `STUNNEL_` to `STUNNEL_SERVICE_`
* Change how SSL certificates are handled - use an environment variable rather
  than require volumne mounts.

  Require a JSON document in `STUNNEL_SSL` environment variable with `cert`,
  `key`, and `chain` parameters

## v2

* Don't run deamon as root

## v1

* Initial release
