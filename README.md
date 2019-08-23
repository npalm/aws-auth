# AWS secrets management for command line

A set of bash function to handle your AWS secrets stored in pass or OSX Keychain.

## TL:TR
Avoid storing secrets in a plain text file. Requires console password manager [pass](https://www.passwordstore.org/) or OSX Keychain.
```bash
source aws-auth-utils.sh
## insert secrets
aws-auth-create-secret-access-keys home
## aws login
aws-auth-login home
```

## Avoid AWS secrets in plain text

The bash script `aws-auth-utils.sh` contain several methods to use AWS cli without storing secrets in plain text in a credentials file. It required the command line password manager [pass](https://www.passwordstore.org/) or OSX Keychain. There is support for with and without the use of MFA. 

The following function are available, all support the option `-help` to see some basic help information.
- aws-auth-mfa-login - set shell environment for AWS using MFA.
- aws-auth-login - set shell environment for AWS without using MFA.
- aws-auth-activate-profile - activates a profile.
- aws-auth-deactivate-profile - deactivate a profile.
- aws-auth-clear - clear AWS related environment variables.
- aws-auth-create-secret-access-keys - to insert access keys in the password store.
- aws-auth-create-secret-mfa - to insert MFA arn in the password store.
- aws-auth-mfa-devices-for-user - list mfa devices for a user.

Due to [a bug](https://github.com/aws/aws-cli/issues/3875) in the AWS cli the `AWS_PROFILE` variable is not interpreted by the AWS cli. Therefor a `aws-activate-profile` function alias the aws command to append `--profile` for the activated profile.

## Usages
Source the functions into your shell environment. The functions requires `jq` for parsing JSON objects. For storting password by default `pass` is used. By setting the environment `AWS_AUTH_PASSWORD_STORE=OSX_KEYCHAIN` you can switch to the OSX password manager.


```bash
source aws-auth-utils.sh
```

Insert secrets for your aws accountX into pass.
```bash
aws-auth-create-secret-access-keys accountX
```

Next add the MFA device ARN to pass for the same account.

```bash
aws-auth-create-secret-mfa accountX
```

Now you can simply obtain an AWS session token.
```bash
aws-auth-mfa-login accountX 123456
# verify you can access your account:
aws sts get-caller-identity
```
Activate profile (switch role) to access another account. Cross account access needs to be setup on AWS.

A configuration like below is expected in your `~/.aws/config` file.
```
[profile accountY]
role_arn = arn:aws:iam::123456789:role/AllowAccessFromAccountX
credential_source = Environment
```

Now simply activate the profile to access accountY
```bash
aws-auth-activate-profile accountY
# verify you can access your account:
aws sts get-caller-identity
```