# AWS secrets management for command line

## TL:TR
Avoid storing secrets in a plain text file. Requires console password manager [pass](https://www.passwordstore.org/).
```bash
source aws-auth-utils.sh
## insert secrets
aws-pass-insert-access-keys home
## aws login
aws-login home
```

## Avoid AWS secrets in plain text

The bash script `aws-auth-utils.sh` contain several methods to use AWS cli without storing secrets in plain text in a credentials file. It required the command line password manager [pass](https://www.passwordstore.org/). There is support for with and withoud the use of MFA.

The following function are available, all support the option `-help` to see some basic help information.
- aws-mfa-login - set shell environment for AWS using MFA.
- aws-login - set shell environment for AWS without using MFA.
- aws-activate-profile - activates a profile.
- aws-deactivate-profile - deactivate a profile.
- aws-clear - clear AWS related environment variables.
- aws-pass-insert-access-keys - to insert access keys in pass.
- aws-pass-insert-mfa - to insert MFA arn in pass.
- aws-mfa-devices-for-user - list mfa devices for a user.

Due to [a bug](https://github.com/aws/aws-cli/issues/3875) in the AWS cli the `AWS_PROFILE` variable is not interpreted by the AWS cli. Therefor a `aws-activate-profile` function alias the aws command to append `--profile` for the activated profile.

## Usages
Source the functions into your shell environment.
```bash
source aws-auth-utils.sh
```

Insert secrets for your aws accountX into pass.
```bash
aws-pass-insert-access-keys accountX
```

Next add the MFA device ARN to pass for the same account.

```bash
aws-pass-insert-mfa accountX
```

Now you can simply obtain an AWS session token.
```bash
aws-mfa-login accountX 123456
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
aws-activate-profile accountY
# verify you can access your account:
aws sts get-caller-identity
```