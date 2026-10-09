#!/bin/bash
jq -c '{"google-auth_token": .["google-auth_token"]}' /tmp/ebs.json
