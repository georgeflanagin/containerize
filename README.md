# containerize
Scripts to assist with common container constructions using podman

- Create, or use an existing non-LDAP user to build containers. If you
    need to create one, do something like this:

```bash
UID_BASE=200000
COUNT=65536

useradd -m pyxidarius
usermod -aG wheel pyxidarius
usermod --add-subuids ${UID_BASE}-${COUNT} pyxidarius
usermod --add-subgids ${UID_BASE}-${COUNT} pyxidarius
```

- Enable the user to run containers even when not logged in.

```bash
loginctl enable-linger pyxidarius
```

- Login as the new user, and run
```bash
podman system migrate
```

- Choose a directory where containers will be built. There are 
    advantages to collecting the container construction into a
    single directory.
- Place this script in the directory.
- Run it with an argument that will be the name of the container.

```bash
./containerize.sh mycontainername
```
You will have these directories and files, and the editor
will open the `install.sh` file and the `Containerfile` for
editing.

```bash
├── build-mycontainername
│   ├── Containerfile
│   ├── install.sh*
│   └── mycontainername/
```


