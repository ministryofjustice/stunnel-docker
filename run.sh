#!/bin/bash

set -e

confd -onetime -backend env

cat /tmp/stunnel.cnf

exec stunnel /tmp/stunnel.cnf
