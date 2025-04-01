# containerize

Scripts to assist with common application container constructions 
using podman and apptainer, together. 

**IMPORTANT** The script, `containerize.sh`, can be run multiple times
to build the container without worrying about overwriting the 
customizations you have made to the `Containerfile` or the `install.sh`
files that you have modified.


## First steps

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

- Login as the new user (pyxidarius), and run
```bash
./containerize.sh mycontainername --build
```

```bash
podman system migrate
```

- Choose a directory where containers will be built. There are 
    advantages to collecting the container construction into a
    single directory.
- Place this script in the directory.
- Run this script with an argument that will be the name of the container.

```bash
./containerize.sh mycontainername
```

You will have these subdirectories and files, and the editor
will open the `install.sh` file and the `Containerfile` for
editing.

```bash
├── build-mycontainername
│   ├── Containerfile
│   ├── install.sh*
│   └── mycontainername/
```

## Next steps

- `install.sh` adds files to the container's temporary file system.

- `Containerfile` defines the organization of the container, and the commands
    to be run at startup.

The following command will attempt to build the container.

```bash
./containerize.sh mycontainername --build
```

If you also want a file for apptainer/singularity, you can add one more
parameter to create `mycontainername.sif`:

```bash
./containerize.sh mycontainername --build --cluster
```



