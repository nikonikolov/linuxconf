# Linux Configuration Scripts

## Slackware
- Assumes that the directory is locally copied
- You need to clone packages with `git lfs`

## Ubuntu
- Different functionality for local machines and server machines

### Local Machine
- Assumes that the directory is locally copied

### Servers
- Assumes that the directory is locally copied
- Provides some basic functionality for logging remotely to a server
and executing the code
- To copy your ssh keys to the server:
```
cat $HOME/.ssh/id_rsa.pub | ssh user@hostname "cat - >> .ssh/authorized_keys"
```