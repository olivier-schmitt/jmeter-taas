#!/usr/bin/env bash
export TAAS_DAV_USERNAME=admin
export TAAS_DAV_PASSWORD=admin
export TAAS_RMI_SERVER_HOSTNAME=$(ipconfig getifaddr en1)
docker run --rm -it -e TAAS_RMI_SERVER_HOSTNAME -e TAAS_DAV_USERNAME -e TAAS_DAV_PASSWORD  -p 1099:1099 -p 1100:1100 -p 80:80 quay.io/olivier_schmitt/jmeter-taas:3.3