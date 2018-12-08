# Linux Configuration Scripts

## Slackware
- Assumes that the directory is locally copied
- You need to clone packages with `git lfs`
- On a first time setup, enable `sudo`, NetworkManager and connect to the internet
- Then run
```
./slackware/configure.sh
./slackware/install.sh
```
- When you install `bumblebee`, run
```
./slackware/configure_nvidia.sh
```

## Ubuntu
- Different functionality for local machines and server machines

### Local Machine
- Assumes that the directory is locally copied
- On a first time setup run
```
./ubuntu/configure.sh
```

### Servers
- Assumes that the directory is locally copied
- Provides some basic functionality for logging remotely to a server
and executing the code
- To copy your ssh keys to the server:
```
cat $HOME/.ssh/id_rsa.pub | ssh user@hostname "cat - >> .ssh/authorized_keys"
```
- On a first time setup run **on the server**
```
./ubuntu/configure_server.sh
```
