#!/usr/bin/env bash

function crash {
    echo "ERROR: $1" >&2
    exit 1
}

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

function modrinthModVersions {
    local versions=$(curl -sS "https://api.modrinth.com/v2/project/$1/version?loaders=%5B%22$LOADER%22%5D&game_versions=%5B%22$MC_VERSION%22%5D")
    if [ "$(echo "$versions" | jq -r ".[0]")" = "null" ]; then
        crash "Could not find mod/modpack on Modrinth for LOADER $LOADER and MC_VERSION $MC_VERSION: $1"
    fi
    echo $versions
}

function checkSha1 {
    echo "$1 $2" | sha1sum -c 2>/dev/null
}

defaultIfNotSet MC_VERSION latest
defaultIfNotSet LOADER vanilla
defaultIfNotSet FORGE_VERSION recommended
defaultIfNotSet OVERWRITE false

versionManifest=$(curl -sS "https://launchermeta.mojang.com/mc/game/version_manifest.json")

if [ "$MC_VERSION" = "latest" ]; then
    MC_VERSION=$(echo $versionManifest | jq -r ".latest.release")
fi

step "Installing server"

case $LOADER in
    fabric)
        fabric-installer server -downloadMinecraft -mcversion "$MC_VERSION"
        ;;
    forge)
        if [ "$FORGE_VERSION" = "recommended" ] || [ "$FORGE_VERSION" = "latest" ]; then
            promotions=$(curl -sSL "https://files.minecraftforge.net/maven/net/minecraftforge/forge/promotions_slim.json")
            FORGE_VERSION=$(echo $promotions | jq -r ".promos.\"$MC_VERSION-$FORGE_VERSION\"")
            if [ -z "$FORGE_VERSION" ]; then
                crash "Could not find Forge version for Minecraft $MC_VERSION!"
            fi
        fi
        versionString="$MC_VERSION-$FORGE_VERSION"
        curl -sS "https://maven.minecraftforge.net/net/minecraftforge/forge/$versionString/forge-$versionString-installer.jar" > forge-installer.jar
        java -jar forge-installer.jar --installServer
        ;;
    vanilla)
        versionInfoUrl=$(echo $versionManifest | jq -r ".versions[] | select(.id == \"$MC_VERSION\") | .url")
        versionInfo=$(curl -sS "$versionInfoUrl")
        sha1=$(echo $versionInfo | jq -r ".downloads.server.sha1")
        if [ "$OVERWRITE" = "true" ] || ! checkSha1 "$sha1" server.jar; then
            echo "Downloading server.jar..."
            url=$(echo $versionInfo | jq -r ".downloads.server.url")
            curl -sS "$url" > server.jar
        fi
        ;;
    *)
        crash "Invalid LOADER: $LOADER. Must be one of: fabric forge vanilla"
        ;;
esac

if [ "$LOADER" != "vanilla" ] && [ -n "$MODRINTH_MODPACK" ]; then
    step "Installing modpack"

    packVersion=$(modrinthModVersions "$MODRINTH_MODPACK" | jq -r ".[0]")
    file=$(echo $packVersion | jq -r ".files[0]")
    filename=$(echo $file | jq -r ".filename")
    if [[ ! "$filename" == *.mrpack ]]; then
        crash "Invalid MODPACK: $MODPACK. $filename does not have the .mrpack extension."
    fi
    sha1=$(echo $file | jq -r ".hashes.sha1")
    if [ "$OVERWRITE" = "true" ] || ! checkSha1 "$sha1" "$filename"; then
        echo "Downloading $filename..."
        url=$(echo $file | jq -r ".url")
        curl -sS "$url" > "$filename"
    fi
    unzip -qo "$filename"
    chmod -R 700 modrinth.index.json overrides
    nFiles=$(jq -r ".files | length" modrinth.index.json)
    for ((i=0; i<nFiles; i++)); do
        file=$(jq -r ".files[$i]" modrinth.index.json)
        server=$(echo $file | jq -r ".env.server")
        if [ "$server" = "required" ]; then
            path=$(echo $file | jq -r ".path")
            sha1=$(echo $file | jq -r ".hashes.sha1")
            if [ "$OVERWRITE" = "true" ] || ! checkSha1 "$sha1" "$path"; then
                echo "Downloading $path..."
                url=$(echo $file | jq -r ".downloads[0]")
                dir=$(dirname "$path")
                if [ ! -d "$dir" ]; then
                    mkdir -p "$dir"
                fi
                curl -sS "$url" > "$path"
            fi
        fi
    done
    echo "Applying overrides..."
    rsync -aI overrides/ .
fi

if [ "$LOADER" != "vanilla" ] && [ -n "$MODRINTH_MODS" ]; then
    step "Installing mods"

    mkdir -p mods
    cd mods
    for mod in $MODRINTH_MODS; do
        modVersion=$(modrinthModVersions "$mod" | jq -r ".[0]")
        nFiles=$(echo $modVersion | jq -r ".files | length")
        for ((i=0; i<nFiles; i++)); do
            file=$(echo $modVersion | jq -r ".files[$i]")
            filename=$(echo $file | jq -r ".filename")
            sha1=$(echo $file | jq -r ".hashes.sha1")
            if [ "$OVERWRITE" = "true" ] || ! checkSha1 "$sha1" "$filename"; then
                echo "Downloading $filename..."
                url=$(echo $file | jq -r ".url")
                curl -sS "$url" > "$filename"
            fi
        done
    done
    cd ..
fi
