# Defined in - @ line 1
function aws_mfa_login
  echo 'You are asking AWS to login with MFA. Removing current saved login tokens'
  set -eg AWS_ACCESS_KEY_ID
  set -eg AWS_SECRET_ACCESS_KEY
  set -eg AWS_SESSION_TOKEN
  # Get the serial and token
  set -l _mfaSerialNumber (aws configure get mfa_serial --profile default)
  echo "AWS local serial that we got is -->{$_mfaSerialNumber}<-- and arguments are $argv"
  set -l _awsSessionToken (aws sts get-session-token --serial-number $_mfaSerialNumber --token-code $argv)
  #echo "Token that we got it -->{$_awsSessionToken}<--"
  if [ "{$_awsSessionToken}" = "{}" ]
    echo "Token was not correct or not receaved properly from AWS"
  else 
    echo "Setting Environment variables AWS_*"
    set -l expire (echo $_awsSessionToken | jq -r '.Credentials.Expiration')
    set -gx AWS_SESSION_TOKEN (echo $_awsSessionToken | jq -r '.Credentials.SessionToken')
    # echo AWS session token is \n$AWS_SESSION_TOKEN
    set -gx AWS_SECRET_ACCESS_KEY (echo $_awsSessionToken | jq -r '.Credentials.SecretAccessKey')
    set -gx AWS_ACCESS_KEY_ID (echo $_awsSessionToken | jq -r '.Credentials.AccessKeyId')
    echo MFA session valid until $expire
  end
end
