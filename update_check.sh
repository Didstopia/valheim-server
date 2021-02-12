#!/usr/bin/env bash

set -m

# Check if we are auto-updating or not
if [ "$VALHEIM_UPDATE_CHECKING" = "1" ]; then
	echo "Checking Steam for updates.."
else
	exit
fi

# Get the old build id (default to 0)
OLD_BUILDID=0
if [ -f "/steamcmd/valheim/build.id" ]; then
	OLD_BUILDID="$(cat /steamcmd/valheim/build.id)"
fi

# Minimal validation for the update branch
STRING_SIZE=${#VALHEIM_BRANCH}
if [ "$STRING_SIZE" -lt "1" ]; then
	VALHEIM_BRANCH=public
fi

# Remove the old cached app info if it exists
if [ -f "/app/Steam/appcache/appinfo.vdf" ]; then
	rm -fr /app/Steam/appcache/appinfo.vdf
fi

# Get the new build id directly from Steam
NEW_BUILDID="$(/steamcmd/steamcmd.sh +login anonymous +app_info_update 1 +app_info_print "896660" +quit | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$VALHEIM_BRANCH\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | sed "s/ buildid //g" | xargs)"

# Check that we actually got a new build id
STRING_SIZE=${#NEW_BUILDID}
if [ "$STRING_SIZE" -lt "6" ]; then
	echo "Error getting latest server build id from Steam, automatic updates disabled.."
	exit
fi

# Skip update checking if this is the first time
if [ ! -f "/steamcmd/valheim/build.id" ]; then
	echo "First time running update check (server build id not found), skipping update.."
	echo $NEW_BUILDID > /steamcmd/valheim/build.id
	exit
else
	STRING_SIZE=${#OLD_BUILDID}
	if [ "$STRING_SIZE" -lt "6" ]; then
		echo "First time running update check (server build id empty), skipping update.."
		echo $NEW_BUILDID > /steamcmd/valheim/build.id
		exit
	fi
fi

# Check if the builds match and quit if so
if [ "$OLD_BUILDID" = "$NEW_BUILDID" ]; then
	echo "Build id $OLD_BUILDID is already the latest, skipping update.."
	exit
else
	echo "Latest server build id ($NEW_BUILDID) is newer than the current one ($OLD_BUILDID), initiating update.."
	echo $NEW_BUILDID > /steamcmd/valheim/build.id
	child=$(pidof -s valheim_server.x86_64)
  kill -2 $child
  sleep 5
	exit
fi
