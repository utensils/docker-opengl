#!/bin/sh

if [ $# -eq 0 ]; then
	echo "No command was given to run, exiting."
	exit 1
else
	# Start Xvfb
	echo "Starting Xvfb"
	Xvfb :99 -ac -screen 0 "$XVFB_WHD" -nolisten tcp &
	Xvfb_pid="$!"
	echo "Waiting for Xvfb to be ready..."
	while ! xdpyinfo -display "${DISPLAY}" > /dev/null 2>&1; do
  		sleep 0.1
	done
	# Execute passed command.
	"$@" &
	cmd_pid=$!
	trap "echo 'Stopping'; kill -SIGTERM $Xvfb_pid $cmd_pid" SIGINT SIGTERM
	# Wait for process to end.
	while kill -0 $Xvfb_pid $cmd_pid > /dev/null 2>&1; do
    	wait
	done
fi
