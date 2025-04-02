#!/bin/bash
echo " "
echo "VASA FACIT. MUNDI MUTAT"
echo " "
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <container-name> [--build] [--cluster]"
    exit 1
fi

APP_NAME="$1"
BUILD_FLAG="${2:-}"
CLUSTER="${3:-}"

BUILD_DIR="build-$APP_NAME"
CONTAINERFILE="$BUILD_DIR/Containerfile"
INSTALL_SCRIPT="$BUILD_DIR/install.sh"

# Create build context
mkdir -p "$BUILD_DIR"
mkdir -p "$BUILD_DIR/$APP_NAME"

# Create a base Containerfile if we don't yet have one.
if [[ ! -f "$CONTAINERFILE" ]]; then
    cat > "$CONTAINERFILE" <<EOF


FROM rockylinux:9

COPY install.sh /tmp/install.sh
COPY PLACEHOLDER/ /tmp/PLACEHOLDER/
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm -f /tmp/install.sh

WORKDIR /opt/PLACEHOLDER
CMD ["--help"]
ENTRYPOINT ["PLACEHOLDER"]

EOF
    echo "Created base Containerfile at $CONTAINERFILE"
fi

# Create an install script ONLY if it doesn't exist. We don't
# want to wipe out work we have done.
if [[ ! -f "$INSTALL_SCRIPT" ]]; then
    cat > "$INSTALL_SCRIPT" <<'EOF'
#!/bin/bash
set -euo pipefail

# Give the name of your program.
export MYAPP=PLACEHOLDER

# Always update.
dnf -y update

# Depending on what you might need to install, it is
# a good idea of grab the epel-release repo.
dnf -y install epel-release

# If you need NVIDIA, then uncomment the following line.
# dnf install nvidia-container-toolkit

# Install anything else following this line.
# dnf -y install .....


# The UNIX/Linux FHS says that the app goes in /opt.
mkdir -p /opt/$MYAPP

# Build the application with make, or otherwise collect
# the files for the application

# Clean up if needed
dnf clean all

echo "$MYAPP installed." 

EOF
    sed -i "s/PLACEHOLDER/$APP_NAME/g" "$INSTALL_SCRIPT"
    sed -i "s/PLACEHOLDER/$APP_NAME/g" "$CONTAINERFILE"
    chmod +x "$INSTALL_SCRIPT"
    echo "Created stub install.sh at $INSTALL_SCRIPT"
fi

if [[ "$BUILD_FLAG" == "--build" ]]; then
    echo "Building container image '$APP_NAME'..."
    podman build -t "$APP_NAME" "$BUILD_DIR"
    echo "Image '$APP_NAME' built successfully."
else
    echo "Loading $INSTALL_SCRIPT for editing."
    sleep 2
    "$EDITOR" "$INSTALL_SCRIPT" "$CONTAINERFILE"
    exit
fi

if [[ "$CLUSTER" == "--cluster" ]]; then
    podman save -o "$APP_NAME.tar" "$APP_NAME"
    if [ ! $? ]; then
        echo "Failed to export container to tarball"
        exit
    fi
    sudo apptainer build "$APP_NAME.sif" "docker-archive://$APP_NAME.tar"
    if [ ! $? ]; then
        echo "Failed to build $APP_NAME.sif"
        exit
    fi
