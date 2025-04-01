#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <container-name> [--build]"
    exit 1
fi

APP_NAME="$1"
BUILD_FLAG="${2:-}"

BUILD_DIR="build-$APP_NAME"
CONTAINERFILE="$BUILD_DIR/Containerfile"
INSTALL_SCRIPT="$BUILD_DIR/install.sh"

# Create build context
mkdir -p "$BUILD_DIR"
mkdir -p "$BUILD_DIR/$APP_NAME"

# Create a base Containerfile if it doesn't exist
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

# Create a stub install script if it doesn't exist
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

cd /opt/$MYAPP


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
    vim "$INSTALL_SCRIPT"
fi

