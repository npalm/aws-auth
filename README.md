# AWS access key shell management

While setting up my new MacBook I found it a good moment to avoid storing AWS keys and secrets in any plane text file. Searching the internet I found several approaches. I combined a few of them so I cn now projected my keys and secrets, and use MFA for login.

## Tools
I use [KeyBase](https://keybase.io/) for managing my GPG keys. To export / import GPG keys this blog could be helpful: https://www.elliotblackburn.com/importing-pgp-keys-from-keybase-into-gpg/

For storing secrets I use [pass](https://www.passwordstore.org/), a standard unix password manager. 

## Usages
Too handle several AWS account I use an alias per account, e.q. `home`.

```
Usage: eval $(aws-mfa <name> <token>)

 The scripts expects tho following secrets are stored in the password store pass:
  - <alias>/aws-access-key-id - AWS access key to obtain session token.
  - <alias>/aws-access-secret - AWS secret to obtain session token.
  - <alias>/aws-mfa-arn - AWS MFA arn for two factor login.
```
