#!/bin/bash
set -euo pipefail

# Give the name of your program.
export MYAPP=columbus722

# Always update.
dnf -y update

# Depending on what you might need to install, it is
# a good idea of grab the epel-release repo.
dnf -y install epel-release

tee > /etc/yum.repos.d/oneAPI.repo << EOF
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

dnf -y install intel-cpp-essentials

# If you need NVIDIA, then uncomment the following line.
# dnf install nvidia-container-toolkit

# Install anything else following this line.
dnf -y install libgcc
dnf -y install libxcrypt
dnf -y install mpich
dnf -y install mvapich2
dnf -y install --nogpgcheck openmpi
dnf -y install perl
dnf install -y --setopt=install_weak_deps=False \
    glibc \
    libgcc \
    openmpi \
    openmpi-libs \
 && dnf clean all

# The UNIX/Linux FHS says that the app goes in /opt.
mkdir -p /opt/$MYAPP
mkdir -p /home/cm/cmfp2/programs/Columbus/GIT_OM-new
ln -s /opt/$MYAPP /home/cm/cmfp2/programs/Columbus/GIT_OM-new/Columbus
cp -r /tmp/$MYAPP/* /opt/$MYAPP
# Build the application with make, or otherwise collect
# the files for the application

# Clean up if needed
dnf clean all

echo "$MYAPP installed." 

