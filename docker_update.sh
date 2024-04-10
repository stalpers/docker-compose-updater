#!/bin/bash

export CONFIG=update.json

if ! command -v jq &> /dev/null
then
    echo "[ERROR] Requirements not met - jq could not be found"
    echo "Please install jq (apt install jq)"
    exit 1
fi

SERVICE="$( jq -r .service $CONFIG )"
readarray -t SERVICES < <(jq -r '.services[]' update.json)
DO_BACKUP="$( jq -r .backup $CONFIG )"
DO_CLEANUP_OLD="$( jq -r .remove_old $CONFIG )"
BACKUP_DIR="$( jq -r .backup_dir $CONFIG )"
DATA_DIR="$( jq -r .data_dir $CONFIG )"
COMPOSE_FILE="$( jq -r .compose_file $CONFIG )"

function update() {
  echo "[INFO] Download & recreate $1"
  docker-compose -f "$COMPOSE_FILE" pull "$1"
  docker-compose -f "$COMPOSE_FILE" up -d "$1"
}

if [ ! -f "$COMPOSE_FILE" ]; then
        echo "[ERROR] Docker Compose File not found; ABORTING ($COMPOSE_FILE)"
        exit 99
fi

echo "[INFO] Backing up directory ($DATA_DIR)"
if [ "$DO_BACKUP" == "YES" ]; then
        if [ ! -d "$BACKUP_DIR" ]; then
                echo "[ERROR] Backup directory not found; ABORTING ($BACKUP_DIR)"
                exit 99
        fi
        if [ ! -d "$DATA_DIR" ]; then
                echo "[ERROR] data directory not found; ABORTING ($DATA_DIR)"
                exit 99

        fi
        echo "[INFO] Creating TAR"
        #echo "[DEBUG] " ./$BACKUP_DIR/data_$(date +"%Y%m%d_%H%M%S") ./$DATA_DIR
        tar -czvf ./$BACKUP_DIR/data_$(date +"%Y%m%d_%H%M%S") ./$DATA_DIR
else
        echo "[SKIP] Nothing to do"
fi

for SERVICE in "${SERVICES[@]}"; do
    update "$SERVICE"
done

echo "[INFO] Remove old images"
if [ "$DO_CLEANUP_OLD" == "YES" ]; then
        docker image prune
else
        echo "[INFO] Skipping"
fi
