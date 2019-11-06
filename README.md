# AWS secrets management for command line

A set of bash/zsh function to handle your AWS secrets stored in a password store, supported stores pass, LastPass, and OSX Keychain.

## TL:TR

Avoid storing secrets in a plain text file. Requires console password manager [pass](https://www.passwordstore.org/). OSX Keychain, or lastpass-cli

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
- aws-auth-create-secrets - to insert access keys and mfa arn in the password store.
- aws-auth-create-secret-access-keys - to insert access keys in the password store.
- aws-auth-create-secret-mfa - to insert MFA arn in the password store.
- aws-auth-mfa-devices-for-user - list mfa devices for a user.

Due to [a bug](https://github.com/aws/aws-cli/issues/3875) in the AWS cli the `AWS_PROFILE` variable is not interpreted by the AWS cli. Therefor a `aws-activate-profile` function alias the aws command to append `--profile` for the activated profile.

## Supported password stores

The default password store is `pass` a standard store for the unix command line. By setting the environment variable `AWS_AUTH_PASSWORD_STORE` you can switch to one of the supported password manager. The following are supported.

- [pass](https://www.passwordstore.org/)
- [LastPass](https://github.com/lastpass/lastpass-cli) - `AWS_AUTH_PASSWORD_STORE=LPASS`
- OSX Keycahin - `AWS_AUTH_PASSWORD_STORE=OSX_KEYCHAIN`

You can insert secrets via the commands `aws-auth-create-secrets`, `aws-auth-create-secret-access-keys` and `aws-auth-create-secret-mfa`

Secrets will be stores using an alias in the store.

- pass: alias will be the `path` in pass.
- LastPass: alias will be the `folder` in LastPass
- OSX Keycahin: alias will be the `name` in Keychain

## Usages

Source the functions into your shell environment. The functions requires `jq` for parsing JSON objects. For storting password by default `pass` is used.

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

```toml
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
