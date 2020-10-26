#!/bin/bash
# inputs needed - user name (user) and MFA code (TOKEN)
# echo $@


USAGE="sessioner.sh -u <your AWS user> -t <MFA OTP token> -a <your AWS account ID>"

if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -u|--user)
    USER="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--token)
    TOKEN="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--account)
    ACCOUNT="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


# Change these to match your environments' AWS account IDs and IAM user names
SERIAL="arn:aws:iam::$ACCOUNT:mfa/$USER"
#echo $SERIAL

echo "Configuring $USER with token $TOKEN"
CREDJSON="$(aws sts get-session-token --profile work --duration-seconds 129600 --serial-number $SERIAL --token-code $TOKEN)"
#echo $CREDJSON


ACCESSKEY="$(echo $CREDJSON | jq '.Credentials.AccessKeyId' | sed 's/"//g')"
SECRETKEY="$(echo $CREDJSON | jq '.Credentials.SecretAccessKey' | sed 's/"//g')"
SESSIONTOKEN="$(echo $CREDJSON | jq '.Credentials.SessionToken' | sed 's/"//g')"


#echo "Profile $PROFILENAME AccessKey $ACCESSKEY SecretKey $SECRETKEY"
#echo "SessionToken $SESSIONTOKEN"


aws configure set aws_access_key_id $ACCESSKEY --profile default
aws configure set aws_secret_access_key $SECRETKEY --profile default
aws configure set aws_session_token $SESSIONTOKEN --profile default
