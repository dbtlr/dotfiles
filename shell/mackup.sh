#!/usr/bin/env bash

export STORAGE_MACKUP_DIR="~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Mackup"

if [ ! -d .mackup ]; then
	cd ~

	while [ ! -d "$STORAGE_MACKUP_DIR" ]; do
		echo "Waiting for iCloud Mackup folder ($STORAGE_MACKUP_DIR)..."
		sleep 60
	done

	FILECOUNT=$(find "$STORAGE_MACKUP_DIR" -type f | wc -l)
	FILECOUNT_CLEAN=$(echo "$FILECOUNT" | tr -d '[[:space:]]')

	while [ $FILECOUNT_CLEAN -lt 500 ]; do
		echo "Waiting for iCloud Mackup files A..."
		sleep 10
		FILECOUNT=$(find "$STORAGE_MACKUP_DIR" -type f | wc -l)
		FILECOUNT_CLEAN=$(echo "$FILECOUNT" | tr -d '[[:space:]]')
	done

	/usr/local/bin/mackup restore
fi