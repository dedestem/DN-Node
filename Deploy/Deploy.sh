#!/bin/bash

#?Configuratie
NODE_DIR="DN-Node/"
BRANCH="main"
LOG_FILE="Node.log"
NODE_NAME="DN-Node"
ENTRY_FILE="index.js"
REPO_URL="https://github.com/dedestem/DN-Node.git"
DEPLOY_VER="1"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Deploy start
log "Deploy gestart"

# Get REPO
if [ -d "$NODE_DIR" ]; then
    cd $NODE_DIR
    log "Local Repo gevonden - Repo updaten!"
    git fetch origin $BRANCH >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        log "Error: git fetch failed"
        exit 1
    fi
    git reset --hard origin/$BRANCH >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        log "Error: git reset failed"
        exit 1
    fi
else
    log "Local Repo niet gevonden - Repo ophalen van cloud!"
    git clone $REPO_URL $NODE_DIR >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        log "Error: git clone failed"
        exit 1
    fi
    cd $NODE_DIR
fi

# Get Info.json
COMMIT_HASH=$(git rev-parse HEAD)
echo "{ \"Commit\": \"$COMMIT_HASH\", "InfoVersion": 1 }" > "Info.json"
mv Info.json "$NODE_DIRInfo.json"
log "Using commit: $COMMIT_HASH"

# Installeer dependencies
log "Installing dependencies"
npm install >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
    log "Error: npm install failed"
    exit 1
fi

# Start node
log "Starting node"
if screen -list | grep -q "$NODE_NAME"; then
    log "Screen session detected! $NODE_NAME already running. Closing previous node!"
    screen -S "$NODE_NAME" -X quit
fi

screen -dmS "$NODE_NAME" node $ENTRY_FILE >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
    log "Error: failed to start node"
    exit 1
fi

log "Node $NODE_NAME running."
log "Deploy complete"
