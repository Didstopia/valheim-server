#!/usr/bin/env bash

# Enable debugging
# set -x

# Print the user we're currently running as
echo "Running as user: $(whoami)"

child=0

exit_handler()
{
	echo "Shutdown signal received.."

  # Send SIGINT to server process and wait for it to finish
  kill -2 $child
  wait "$child"

	echo "Exiting.."
	exit
}

# Trap specific signals and forward to the exit handler
trap 'exit_handler' SIGINT SIGTERM

# Valheim includes a 64-bit version of steamclient.so, so we need to tell the OS where it exists
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/steamcmd/valheim/linux64

# Fix missing Steam app id env var
export SteamAppId=892970

# Export the config dir
export VALHEIM_CONFIG_DIR="/app/.config/unity3d/IronGate/Valheim"

# Define the install/update function
install_or_update()
{
	# Install Valheim from install.txt
	echo "Installing/updating Valheim.. (this might take a while, be patient)"
	/steamcmd/steamcmd.sh +runscript /app/install.txt

	# Terminate if exit code wasn't zero
	if [ $? -ne 0 ]; then
		echo "Exiting, steamcmd install or update failed!"
		exit 1
	fi
}

# Check which branch to use
if [ ! -z ${VALHEIM_BRANCH+x} ]; then
	echo "Using branch arguments: $VALHEIM_BRANCH"

	# Add "-beta" if necessary
	INSTALL_BRANCH="${VALHEIM_BRANCH}"
	if [ ! "$VALHEIM_BRANCH" == "public" ]; then
		INSTALL_BRANCH="-beta ${VALHEIM_BRANCH}"
	fi
	sed -i "s/app_update 896660.*validate/app_update 896660 $INSTALL_BRANCH validate/g" /app/install.txt
else
	sed -i "s/app_update 896660.*validate/app_update 896660 validate/g" /app/install.txt
fi

# Install/update steamcmd
echo "Installing/updating steamcmd.."
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | bsdtar -xvf- -C /steamcmd

# Disable auto-update if start mode is 2
if [ "$VALHEIM_START_MODE" = "2" ]; then
	# Check that Valheim exists in the first place
	if [ ! -f "/steamcmd/valheim/valheim_server.x86_64" ]; then
		install_or_update
	else
		echo "Valheim seems to be installed, skipping automatic update.."
	fi
else
	install_or_update

	# Run the update check if it's not been run before
	if [ ! -f "/steamcmd/valheim/build.id" ]; then
		/app/update_check.sh
	else
		OLD_BUILDID="$(cat /steamcmd/valheim/build.id)"
		STRING_SIZE=${#OLD_BUILDID}
		if [ "$STRING_SIZE" -lt "6" ]; then
			/app/update_check.sh
		fi
	fi
fi

# Start mode 1 means we only want to update
if [ "$VALHEIM_START_MODE" = "1" ]; then
	echo "Exiting, start mode is 1.."
	exit
fi

# Start cron
echo "Starting scheduled task manager.."
node /app/scheduler_app/app.js &

# Set the working directory
cd /steamcmd/valheim

# Sanitize the world name
VALHEIM_SERVER_WORLD_SANITIZED=$(echo -n "${VALHEIM_SERVER_WORLD}" | tr -s -c [:alnum:] _)
echo "Sanitized world name: ${VALHEIM_SERVER_WORLD_SANITIZED}"

# Migrate worlds if necessary (old bug with an extra _ suffix for the world names)
LOCAL_WORLD_PATH="${VALHEIM_CONFIG_DIR}/worlds/${VALHEIM_SERVER_WORLD_SANITIZED}"
if [[ ! -f "${LOCAL_WORLD_PATH}.db" ]]; then
	if [[ -f "${LOCAL_WORLD_PATH}_.db" ]]; then
		mv "${LOCAL_WORLD_PATH}_.db" "${LOCAL_WORLD_PATH}.db"
	fi
fi
if [[ ! -f "${LOCAL_WORLD_PATH}.fwl" ]]; then
	if [[ -f "${LOCAL_WORLD_PATH}_.fwl" ]]; then
		mv "${LOCAL_WORLD_PATH}_.fwl" "${VALHEIMLOCAL_WORLD_PATH}.fwl"
	fi
fi

# Set the admin user if specified
if [ ! -z ${VALHEIM_BRANCH+x} ]; then
  echo "Setting up server admins (one Steam ID per line): ${VALHEIM_SERVER_ADMINS}"
  mkdir -p ${VALHEIM_CONFIG_DIR}
  touch ${VALHEIM_CONFIG_DIR}/adminlist.txt
  grep -qxF "${VALHEIM_SERVER_ADMINS}" ${VALHEIM_CONFIG_DIR}/adminlist.txt || echo "${VALHEIM_SERVER_ADMINS}" > ${VALHEIM_CONFIG_DIR}/adminlist.txt
fi

# Run the server
/steamcmd/valheim/valheim_server.x86_64 ${VALHEIM_SERVER_STARTUP_ARGUMENTS} -public ${VALHEIM_SERVER_PUBLIC} -port "${VALHEIM_SERVER_PORT}" -name "${VALHEIM_SERVER_NAME}" -world "${VALHEIM_SERVER_WORLD_SANITIZED}" -password "${VALHEIM_SERVER_PASSWORD}" | egrep -iv '^((\(Filename: .*\))|([[:space:]]*))$' &
sleep 2
child=$(pidof -s valheim_server.x86_64)
wait "$child"

echo "Exiting.."
exit
