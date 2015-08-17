#!/bin/bash

set -e

confd -onetime -backend env
chmod 600 /home/stunnel/*

exec stunnel /home/stunnel/stunnel.cnf
