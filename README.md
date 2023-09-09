
# Step-by-step wrapper for git/github push and merge via command line

Pure bash.

By default *git add* use -A option (all new/changed files is added to commit).

<br>

## Adapted for easy use GitHub's fine-grained personal access token
GitHub's fine-grained personal access token is encrypted with AES and stored in .git/config.
With first run you will be prompted for personal access token.
It will be encrypted and never stored unencrypted (neither in environment variables nor in file).

<br>

## External tools used
- openssl

<br>

## Usage
Just clone and run within your local git repo folder.

With first run script will try to create softlink to itself in */usr/local/bin* folder.
