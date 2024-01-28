
# Step-by-step wrapper for git/github push and merge via command line

Useful for script development directly on target host (e.g. servers without GUI).

Pure bash.

Inspired with github auth system via tokens (and prohibited login/password auth for command line git).

<br>

## Adapted for easy use GitHub's fine-grained personal access token
GitHub's fine-grained personal access token is encrypted with AES and stored in .git/config.
With first run within local repo folder you will be prompted for fine-grained personal access token.
It will be encrypted and never stored unencrypted (neither in environment variables nor in file).

<br>

## External tools used
- openssl

<br>

## Usage
Create new repo on github.com.


Just clone and run github-push-and-merge. For system-wide runniing you will be prompted (with first run) to create softlink to this script in */usr/local/bin* folder (requires sudo rights).
Then you can run github-push-and-merge within your local git repo folder(s). Every step is guided and controlled by exit codes.


<br>

## Defaults 
- *git pull* used before each commit/push.
- *git add* uses -A option (all new/changed files is added to commit).
- *git push* pushes current branch without merging it to main branch.
