#!/bin/bash

set -e

confd -onetime -backend env

exec stunnel /home/stunnel/stunnel.cnf
