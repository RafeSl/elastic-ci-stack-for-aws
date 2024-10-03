#!/bin/bash
set -eu -o pipefail

secret_json=$(aws secretsmanager get-secret-value --secret-id "sanbox/bk/timmy" --query 'SecretString' --output text)

# Parse the JSON and export each key-value pair as an environment variable
for key in $(echo "$secret_json" | jq -r 'keys[]'); do
  value=$(echo "$secret_json" | jq -r --arg key "$key" '.[$key]')
  echo "Setting Key: $key in /etc/profile"
  echo "export $key=$value">> /etc/profile
done