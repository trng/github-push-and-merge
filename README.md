
# Step-by-step wrapper for git/github push and merge via command line

Useful for script development directly on target host (e.g. servers without GUI).

Pure bash.

Inspired with github auth system via tokens (and prohibited login/password auth for command line git).

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

With first run you will be prompted to create softlink to this script in */usr/local/bin* folder (requires sudo rights).

<br>

## Defaults 
- *git pull* used before each commit/push.
- *git add* uses -A option (all new/changed files is added to commit).
- *git push* pushes current branch without merging it to main branch.
