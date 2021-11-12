# AWS fish shell fuctions

A set of fish finctions covering the basic tools in this repository that was meant initially for bash and zsh only.

## Function "aws_mfa_login"

This function goes with argument MFA code, that is needed for your default AWS profile

Usage: "aws_mfa_login \<your MFA code from device registerd on default AWS user defined in aws config file>"

ex.
```fish
aws_mfa_login 456321
```

## Function "aws-switch-to-account-with-role"

This function has an argument of arn format of the role that your current AWS logged in user wants to switch to

Usage: "aws-switch-to-account-with-role arn:aws:iam::\<AWS account id>:role/\<Role name defined for the AWS account id>"

ex.
```fish
aws-switch-to-account-with-role arn:aws:iam::123456789012:role/MyDefinedAdminRole
```
