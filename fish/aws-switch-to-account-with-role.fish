# Defined in - @ line 1
function aws-switch-to-account-with-role
  set -l new_role_arn $argv[1]
  echo You are switching to AWS role {$new_role_arn}
  set -xg _AWS_ACCESS_KEY_ID $AWS_ACCESS_KEY_ID
  set -xg _AWS_SECRET_ACCESS_KEY $AWS_SECRET_ACCESS_KEY
  set -xg _AWS_SESSION_TOKEN $AWS_SESSION_TOKEN
  
  set -l temp_role (aws sts assume-role --role-arn $new_role_arn --duration-seconds 3600 --role-session-name 'temp-switched-role')

  set -gx AWS_ACCESS_KEY_ID (echo $temp_role | jq -r .Credentials.AccessKeyId)
  set -gx AWS_SECRET_ACCESS_KEY (echo $temp_role | jq -r .Credentials.SecretAccessKey)
  set -gx AWS_SESSION_TOKEN (echo $temp_role | jq -r .Credentials.SessionToken)

  echo Switch done.
end
