#!/bin/bash

# Check if the path is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

# Directory to be processed
DIRECTORY=$1

# Check if the provided path is a directory
if [ ! -d "$DIRECTORY" ]; then
    echo "Error: '$DIRECTORY' is not a valid directory."
    exit 1
fi

# Recursively convert DOS/Mac line endings to Unix line endings
echo "Starting conversion of DOS/Mac line endings to Unix line endings in directory $DIRECTORY..."
find "$DIRECTORY" -type f -exec dos2unix {} + 

echo "Conversion completed successfully."
