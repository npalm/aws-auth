#!/usr/bin/env bash

printerr() { printf "%s\n" "$*" >&2; }

aws-auth-utils() {
  if [[ -z $1 || $1 == aws-mfa-login ]] {
    printerr "-------------------------------------"
    printerr "Usage:  aws-mfa-login <path> <token>"
    printerr ""
    printerr "This function creates an AWS MFA session based on secrets and MFA arn stored in the password manager. After creating a session via AWS STS the following vars are set in the environment: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SESSION_TOKEN"
    printerr "  - <path>/aws-access-key-id - AWS access key to set."
    printerr "  - <path>/aws-access-secret - AWS secret to set."
    printerr "  - <path>/aws-mfa-arn - AWS MFA arn for two factor login."
    printerr
  }

  if [[ -z $1 || $1 == aws-login ]] {
    printerr "--------------------------"
    printerr "Usage:  aws-login} <path>"
    printerr ""
    printerr " This sets environment AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY based on stored secrets in the password store pass." 
    printerr "  - <path>/aws-access-key-id - AWS access key to set."
    printerr "  - <path>/aws-access-secret - AWS secret to set."
    printerr
  }

  if [[ -z $1 || $1 == aws-pass-insert-access-keys ]] {
    printerr "--------------------------------------------"
    printerr "Usage:  aws-pass-insert-access-keys} <path>"
    printerr ""
    printerr "Inserts entries into pass for:"
    printerr "  - <path>/aws-access-key-id"
    printerr "  - <path>/aws-access-secret"
    printerr
  }

  if [[ -z $1 || $1 == aws-pass-insert-mfa ]] {
    printerr "------------------------------------"
    printerr "Usage:  aws-pass-insert-mfa <path>"
    printerr ""
    printerr "Inserts entry into pass for:"
    printerr "  - <path>/aws-mfa-arn" 
    printerr
  }
  
  if [[ -z $1 || $1 == aws-cleare ]] {
    printerr "------------------"
    printerr "Usage: ws-clear"
    printerr ""
    printerr "Clears AWS related environment variables and unalias the the aws command."
    printerr
  }

  if [[ -z $1 || $1 == aws-activate-profile ]] {
    printerr "----------------------------------------"
    printerr "Usage:  aws-activate-profile <profile>"
    printerr ""
    printerr "Activate the AWS <profile> and creates an alias for the aws command to append `--profile=<profile\>` to ensure the profile is used."
    printerr
  }

  if [[ -z $1 || $1 == aws-deactivate-profile ]] {
    printerr "--------------------------------"
    printerr "Usage:  aws-deactivate-profile"
    printerr ""
    printerr "De-activate the AWS <profile>."
    printerr
  }

  if [[ -z $1 || $1 == aws-mfa-devices-for-user ]] {
    printerr "--------------------------------"
    printerr "Usage:  aws-mfa-devices-for-user <user-name>"
    printerr ""
    printerr "Look up the MFA device for <user-name>."
    printerr
  }
  
}


aws-activate-profile() {
  if [[ -z $1 || $1 = "-help" ]]; then
    aws-auth-utils aws-activate-profile && return 0
  fi
  export AWS_PROFILE=$1
  alias aws='aws --profile $AWS_PROFILE'
}

aws-deactivate-profile() {
  if [[ $1 = "-help" ]]; then
    aws-auth-utils aws-deactivate-profile && return 0
  fi
  unset AWS_PROFILE
  unalias aws
}


aws-login() {
  if [[ -z $1 || $1 = "-help" ]]; then
    aws-auth-utils aws-login && return 0
  fi

  aws-clear
  export AWS_ACCESS_KEY_ID=$(pass ${alias}/aws-access-key-id)
  export AWS_SECRET_ACCESS_KEY=$(pass ${alias}/aws-access-secret)
}

aws-mfa-login() {
  if [[ -z $1 || -z $2 || $1 = "-help" ]]; then
    aws-auth-utils aws-mfa-login && return 0
  fi

  #aws-clear
  export AWS_ACCESS_KEY_ID=$(pass ${1}/aws-access-key-id)
  export AWS_SECRET_ACCESS_KEY=$(pass ${1}/aws-access-secret)

  _mfaSerialNumber=$(pass ${1}/aws-mfa-arn)
  if [[ ! -z $_mfaSerialNumber || ! -z $token ]]; then
    export _awsSessionToken=$(aws sts get-session-token --serial-number $_mfaSerialNumber --token-code $2)
  fi

  if [[ ! -z $_awsSessionToken ]]; then
    expire=$(echo $_awsSessionToken | jq -r '.Credentials.Expiration')
    export AWS_SESSION_TOKEN=$(echo $_awsSessionToken | jq -r '.Credentials.SessionToken')
    export AWS_SECRET_ACCESS_KEY=$(echo $_awsSessionToken | jq -r '.Credentials.SecretAccessKey')
    export AWS_ACCESS_KEY_ID=$(echo $_awsSessionToken | jq -r '.Credentials.AccessKeyId')
    unset __awsSessionToken
    unset __mfaSerialNumber
    echo MFA session valid until $expire >&1
  else
    echo WARNING: Could not obtain session token >&1
  fi
}

aws-clear() {
  if [[ $1 = "-help" ]]; then
    aws-auth-utils aws-clear && return 0
  fi
  unset AWS_SESSION_TOKEN
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_ACCESS_KEY_ID

  if [[ ! $1 == 'only-env-vars' ]]; then
    aws-deactivate-profile
    if [[ -d ~/.aws/cli/cache ]]; then
      rm -rf ~/.aws/cli/cache
    fi
  fi 
}


aws-pass-insert-mfa() {
  if [[ -z $1 || $1 = "-help" ]]; then
    aws-auth-utils aws-pass-insert-mfa && return 0
  fi
  pass insert ${1}/aws-mfa-arn
}

aws-pass-insert-access-keys() {
  if [[ -z $1 || $1 = "-help" ]]; then
    aws-auth-utils aws-pass-insert-access-keys && return 0
  fi
  pass insert ${1}/aws-access-key-id
  pass insert ${1}/aws-access-secret
}

aws-mfa-devices-for-user() {
  if [[ -z $1 || $1 = "-help" ]]; then
    aws-auth-utils aws-mfa-devices-for-user && return 0
  fi
  echo $(aws iam list-mfa-devices --user-name $1) | jq -r '.MFADevices[].SerialNumber'
}