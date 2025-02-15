# Linux Configuration Scripts

* [Slackware](#slackware)
  * [Automatic setup steps](#slackware-1)
  * [Manual setup steps](#slackware-2)
  * [Install additional pacakges](#slackware-3)
  * [Possible Dependencies](#slackware-4)
* [Ubuntu](#ubuntu)
* [Developing](#developing)
  * [Good practices](#dev-1)
  * [Common tool usage](#dev-2)
  * [TODO](#dev-3)

## Slackware
- Assumes that the directory is locally copied
- You need to clone packages with `git lfs`

### Automatic setup steps

To be able to run the automatic setup, you first need to manually enable sudo and connect to the internet. Then run
```
./slackware/configure.sh
./slackware/install.sh
```

### Manual setup steps

These are steps that either couldn't be automated or the process is very brittle or complicated
1. Configure grub
2. Make initrd
3. Install `virtualbox`
3. Install *The Great Suspender* extension from your sources. Check the `README.md` in its source folder for instructions
4. Install `bumblebee` and `nvidia` drivers
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

### Install additional pacakges

- To install `CUDA`, use your repo and follow the instructions
```
git clone git@github.com:nikonikolov/slackbuilds.git
```

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

---
---

## Developing

### Good practices
1. Installation of new packages goes in `install.sh` scripts. Try to keep any additional configuration for a new package together with the installation
2. Configuration of existing packages and system goes in `configure.sh`
3. Configuration files
  - System files: code up the configuration as part of the scripts. System files change quite often, better just add the custom configuration you need
  - Files which are completely written by you: backup the files and configure on the new system by restoring the copy. Good idea to have backups and use them - higher chance of being up to date and working than coding up in the scripts
4. Packages which aren't updated on slackbuilds.org
  - Try to submit update to a new version
  - If not, add the compilation scripts to this repo and use `installfromsource` utility
  - Avoid adding any `tar` or `zip` files, but download them on the go (the correct links are populated in the `.info` file of the package
  - Only when very problematic, add `tar` or `zip` files via git lfs
5. Package which you maintain on slackbuilds.org go to the (SlackBuilds repo)[https://github.com/nikonikolov/slackbuilds]
6. Package source code
  - All source archives are ignored in `slackware/packages/.gitignore`
  - The workflow requires you download them manually

### Common tool usage
1. Example of getting access to the correct `$USER` variable in a command
```bash
sudo -u $SUDO_USER cp $SLACK_BACKUP_DIR/redshift.conf /home/$SUDO_USER/.config/
```

### TODO

1. Slackware
  - TLP
  - Google Chrome (deprioritized)
  - Don't remember why I needed these packages
    - `graphviz`
    - `portaudio`
    - `xournalapp`