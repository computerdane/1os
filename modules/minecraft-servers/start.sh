function defaultIfNotSet {
    local var_name=$1
    local default_value=$2
    if [ -z "${!var_name}" ]; then
        export $var_name=$default_value
    fi
}

function step {
    echo -e "\033[0;32m"
    echo
    echo "=> $1..."
    echo -e "\033[0m"
}

defaultIfNotSet LOADER vanilla

step "Starting"

case $LOADER in
    fabric)
        java -jar fabric-server-launch.jar --nogui
        ;;
    forge)
        ./run.sh --nogui
        ;;
    vanilla)
        java -jar server.jar --nogui
        ;;
esac
