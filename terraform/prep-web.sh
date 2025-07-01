#!/bin/sh

if ! [ -x "$(command -v jq)" ]; then
  echo 'jq not found, you must install it first. https://jqlang.org/download/' >&2
  exit 1
fi

if ! [ -x "$(command -v aws)" ]; then
  echo 'AWS CLI not found, you must install it first. https://docs.aws.amazon.com/cli' >&2
  exit 1
fi

echo "> Parsing Terraform outputs"
TERRAFORM_OUTPUTS_MAP=$(terraform output --json outputs_map)
#echo $TERRAFORM_OUTPUTS_MAP
AUTH0_CLIENT_ID=$(echo "$TERRAFORM_OUTPUTS_MAP" | jq -r ".auth0_client_id")
AUTH0_CLIENT_SECRET=$(echo "$TERRAFORM_OUTPUTS_MAP" | jq -r ".auth0_client_secret")
AUTH0_CONNECTION_NAME=$(echo "$TERRAFORM_OUTPUTS_MAP" | jq -r ".auth0_connection_name")
AUTH0_SIGN_IN_URL=$(echo "$TERRAFORM_OUTPUTS_MAP" | jq -r ".auth0_sign_in_url")
AUTH0_LOGOUT_URL=$(echo "$TERRAFORM_OUTPUTS_MAP" | jq -r ".auth0_logout_url")
AUTH0_WELL_KNOWN_URL=$(echo "$TERRAFORM_OUTPUTS_MAP" | jq -r ".auth0_well_known_url")
AUTH0_RESOURCE_SERVER_IDENTIFIER=$(echo "$TERRAFORM_OUTPUTS_MAP" | jq -r ".auth0_resource_server_identifier")
AGENT_ENDPOINT_URL=$(echo "$TERRAFORM_OUTPUTS_MAP" | jq -r ".agent_endpoint")


echo "AUTH0_CLIENT_ID=$AUTH0_CLIENT_ID"
echo "AUTH0_CLIENT_SECRET=${AUTH0_CLIENT_SECRET:0:3}....redacted..."
echo "AUTH0_CONNECTION_NAME=$AUTH0_CONNECTION_NAME"
echo "AUTH0_SIGN_IN_URL=$AUTH0_SIGN_IN_URL"
echo "AUTH0_LOGOUT_URL=$AUTH0_LOGOUT_URL"
echo "AUTH0_WELL_KNOWN_URL=$AUTH0_WELL_KNOWN_URL"
echo "AUTH0_RESOURCE_SERVER_IDENTIFIER=$AUTH0_RESOURCE_SERVER_IDENTIFIER"
echo "AGENT_ENDPOINT_URL=$AGENT_ENDPOINT_URL"


DST_FILE_NAME="./../web/.env"
echo "> Injecting values into $DST_FILE_NAME"
echo "" > $DST_FILE_NAME
echo "AUTH0_CLIENT_ID=\"$AUTH0_CLIENT_ID\"" >> $DST_FILE_NAME
echo "AUTH0_CLIENT_SECRET=\"$AUTH0_CLIENT_SECRET\"" >> $DST_FILE_NAME
echo "AUTH0_CONNECTION_NAME=\"$AUTH0_CONNECTION_NAME\"" >> $DST_FILE_NAME
echo "AUTH0_SIGNIN_URL=\"$AUTH0_SIGN_IN_URL\"" >> $DST_FILE_NAME
echo "AUTH0_LOGOUT_URL=\"$AUTH0_LOGOUT_URL\"" >> $DST_FILE_NAME
echo "AUTH0_WELL_KNOWN_URL=\"$AUTH0_WELL_KNOWN_URL\"" >> $DST_FILE_NAME
echo "AUTH0_RESOURCE_SERVER_IDENTIFIER=\"$AUTH0_RESOURCE_SERVER_IDENTIFIER\"" >> $DST_FILE_NAME
echo "AGENT_ENDPOINT_URL=\"$AGENT_ENDPOINT_URL\"" >> $DST_FILE_NAME

echo "> Done"

