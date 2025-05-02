#!/bin/sh

# Create necessary directories if they don't already exist
mkdir -p /opt/cfx-server/data/resources
mkdir -p /opt/cfx-server/data/cache
mkdir -p /opt/cfx-server/data/crashes

# Clear the cache files directory if it exists
if [ -d /opt/cfx-server/data/cache ]; then
	rm -rf /opt/cfx-server/data/cache/files
fi

# Execute the FXServer binary with the provided arguments
exec /opt/cfx-server/ld-musl-x86_64.so.1 FXServer "$@"
