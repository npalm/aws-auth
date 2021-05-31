# A guide for new users
This document is intended to guide a new user through the configuration of the tools environment to the point
where the AWS CLI tools can be used comfortably and securely to work with an account/role on AWS.

## Installation
This guide was written for a osx user and assumes there is a bin directory in your home directory where
you store executables.
- change into your bin directory (or wherever you want to install the scipt) with: `cd ~/bin`
- clone the repo with: `git clone git@github.com:npalm/aws-auth.git` or `https://github.com/npalm/aws-auth.git`
- install pass (see https://www.passwordstore.org/) with: `brew install pass`
- install jq (see https://stedolan.github.io/jq/) with: `brew install jq`
- install the latest version of AWS CLI. Follow the instructions from the installation section on
  https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html

## Configuration
### source the aws-auth-* shell commands
- With you favourite editor open the .rc file of the shell that you are using. For me that is the (standard)
zsh so its: `vi ~/.zshrc`
- Add `[[ -s "/Users/<replace with user>/bin/aws-auth/aws-auth-utils.sh" ]] && source "/Users/<replace with user>/bin/aws-auth/aws-auth-utils.sh"`
  and don't forget to replace both `<replace with user>` with your username.
- create a new shell and verify that the script was loaded by typing `aws-auth` and then hitting tab. When
  installed properly a list of aws-auth commands should be listed.

### initialize pass
- generate a gpg key pair with: `gpg --generate-key` and follow the prompts. Since the purpose of these
  tools is to securely store secrets, put a pass phrase on the key pair and remember it!
- get the public part of the key with: `gpg -k` It is the second line on the `pub` section of the listed keys.
- use the public part of the key to initialize pass with: `pass init <public key part>`

### create secrets to login to the AWS account
- Have your AWS console open on the IAM page for your user and switch to the `security credentials` tab,
  we will need some of its values. You do not need to switch roles for this.
- In the `Sign-in credentials` paragraph check that you have a arn configured for the `Assigned MFA device`.
  The value listed here (`arn:aws:iam::<Account ID>:mfa/<username>` or something similar) must be entered when prompted for the `password for <xyz>/aws-mfa-arn`
- In the `Access keys` paragraph click the `Create...` button and click the `show` link to reveal the full secret.
  Don't close this dialog yet. The access key ID needs to be entered when prompted for `password for <xyz>/aws-access-key-id` and
  the secret needs the be entered when prompted for `password for <xyz>/aws-access-secret`
- start the script with: `aws-auth-create-secrets <username>` I use username, but you are free to use anything
you want to name the account/set of secrets. The script will prompt you for 3 secrets (in my version of the tools
  running the script gave me an error for each value prompted, but everything still worked fine):
  - aws-access-key-id:
  - aws-access-secret:
  - aws-mfa-arn:

### verify
- verify that pass has the secrets stored with: `pass ls`. The output of this command should list a tree
  containing the name we used to group the secrets, with below it leaves for the three secrets we provided.
- it is possible to dig deeped and `pass ls <username>/aws-mfa-arn`, which should reveal the arn...

### use the script to login to aws on the CLI
- get a token from your mfa device for the account and run `aws-auth-mfa-login <username> <token>`
- if successful you are now logged in to the AWS account and can perform commands. `aws s3 ls` (I need to
  do a role switch to a subaccount, so this command will give me an Access Denied)

### profile configuration
- make a directory to store a sub account/profile configuration `mkdir ~/.aws`
- using your favourite editor edit `~/.aws/config` and enter
```
[profile <profile name>]
region=eu-west-1
role_arn=arn:aws:iam::<sub account id>:role/<Role name>
credential_source=Environment
```
- with this config in place, it is now possible to use the --profile switch with the AWS CLI tools and
  execute a command using the role on the sub account. i.e. `aws s3 ls --profile <profile name>` for me now executes
  without problems.

### login to the profile for a longer time
- from the `~/.aws/config` file copy the line `role_arn=<*>` and on the shell prompt execute `export role_arn=<*>`
- now execute `aws sts assume-role --role-arn "$role_arn" --duration-seconds 3600 --role-session-name "test"`
With this command the account is setup to use the profile credentials with credentials that are valid for 1 hour.

### pulling the state
Through the command `terraform state pull > state.txt` terraform exposes the current state in the state.txt file.
Be carefull, this file may also contain some credentials that you want to keep secret!
