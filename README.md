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
- To install bumblebee:
  - First clone your repo
    
    ```
    cd slackware/packages/bumblebee/
    git clone git@github.com:nikonikolov/Bumblebee-SlackBuilds.git
    ```
  
  - Follow your installation instructions
  - When ready, write all nvidia configurations with
    
    ```
    ./slackware/configure_nvidia.sh
    ```

### Installing additional packages

- To install `CUDA`, use your repo and follow the instructions
```
git clone git@github.com:nikonikolov/slackbuilds.git
```

- To install `virtualbox`, just download the files and follow the instructions

- Some old packages are available on your external hard drive:
  - `gcc-arm-none-eabi`
  - `MATLAB`
  - `vagrant`

### Possible Dependencies

Below is a list of additional packages that you **might** need:
- `libxkbcommon` - for `qt5` - get from alien or SBo
- `xvidcore` - for `ffmpeg` (might be needed only for `ffmpeg` from SBo) - get from SBo
- `texlive-extra` - for `texlive` - get from SBo
- `texlive-fonts` - for `texlive` - get from SBo


---


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
