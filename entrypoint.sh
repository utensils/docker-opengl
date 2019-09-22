#!/bin/sh

if [ $# -eq 0 ]; then
	echo "No command was given to run, exiting."
	exit 1
else
	# Start Xvfb
	echo "Starting Xvfb"
	Xvfb :99 -ac -screen 0 "$XVFB_WHD" -nolisten tcp &
	Xvfb_pid="$!"
	echo "Waiting for Xvfb (PID: $Xvfb_pid) to be ready..."
	while ! xdpyinfo -display "${DISPLAY}" > /dev/null 2>&1; do
  		sleep 0.1
	done
	echo "Xvfb is running."
	# Execute passed command.
	"$@"
	trap "echo 'Stopping'; kill -SIGTERM $Xvfb_pid" SIGINT SIGTERM
	# Wait for process to end.
	kill $Xvfb_pid
	echo "Waiting for Xvfb (PID: $Xvfb_pid) to shut down..."
	wait $Xvfb_pid
fi
