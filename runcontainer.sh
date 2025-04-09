function runcontainer
{
    if [ -z "$1" ]; then
        echo "Usage: runcontainer {container_name} [working_directory]"
        echo "  Your working directory will default to $HOME."
        return
    fi

    container_name="$1"
    WORKDIR="${2:-$HOME}"

    avail=$(podman images | awk 'NR > 1 && $1 ~ /^localhost\//' | awk '{print $1}')
    if echo $avail | grep -q $container_name; then
        podman run --rm -it \
          -v "$WORKDIR":/mnt/home \
          -v "/scratch/$USER":/mnt/scratch \
          --workdir /mnt/home \
          "$container_name"
    else
        echo "No container here named $container_name."
        echo "Available containers (minus the 'localhost/') are $avail"
    fi 

}

runcontainer
