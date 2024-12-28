#!/bin/bash

# Configuratie
NODE_DIR="DN-Node/"
BRANCH="main"
LOG_FILE="DN-Node.log"
NODE_NAME="DN-Node"
ENTRY_FILE="index.js"
REPO_URL="https://github.com/dedestem/DN-Node.git"
DEPLOY_VER="1"

# Zet script op om te stoppen bij fout
set -e

# CD to dir of script
cd "$(dirname "$0")" || exit 1

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Controleer op argumenten
if [ "$1" == "Stop" ]; then
    log "Stop-commando ontvangen - Node stoppen"
    if screen -list | grep -q "$NODE_NAME"; then
        screen -S "$NODE_NAME" -X quit
        log "Screen sessie $NODE_NAME gestopt"
    else
        log "Geen actieve screen sessie gevonden voor $NODE_NAME"
    fi
    exit 0
fi

# Deploy start
log "==============================================="
log "Deploy gestart"

# Get REPO
if [ -d "$NODE_DIR" ]; then
    rm -rf "$NODE_DIR"
    git clone $REPO_URL $NODE_DIR >> $LOG_FILE 2>&1
    log "Git clone succesvol"
    cd $NODE_DIR
else
    log "Klonen"
    git clone $REPO_URL $NODE_DIR >> $LOG_FILE 2>&1
    log "Git clone succesvol"
    cd $NODE_DIR
fi

# Verkrijg commit hash en schrijf naar Info.json
COMMIT_HASH=$(git rev-parse HEAD)
cd ..
INFO_FILE="${NODE_DIR}Info.json"  # Correct path
echo "{ \"Commit\": \"$COMMIT_HASH\", \"InfoVersion\": 1 }" > $INFO_FILE
log "Commit hash opgeslagen in $INFO_FILE"

# Installeer dependencies
log "Installeer dependencies"
npm install >> $LOG_FILE 2>&1
log "Dependencies geïnstalleerd"

# Log de Node.js versie voor transparantie
NODE_VERSION=$(node -v)
log "Node.js versie: $NODE_VERSION"

# Start node
log "Starting node"
if screen -list | grep -q "$NODE_NAME"; then
    log "Screen sessie gedetecteerd! $NODE_NAME al draaiend. Sluiten van oude node!"
    screen -S "$NODE_NAME" -X quit
fi

cd "$NODE_DIR"
log "$NODE_NAME node $ENTRY_FILE"
screen -dmS "$NODE_NAME" node $ENTRY_FILE >> $LOG_FILE 2>&1
log "Node gestart in screen sessie $NODE_NAME"

log "Deploy compleet"
