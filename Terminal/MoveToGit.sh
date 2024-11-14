#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <origin_path> <destination_path>"
    exit 1
fi

# Assign arguments to variables
origin_path="$1"
destination_path="$2"

# Check if origin path exists
if [ ! -d "$origin_path" ]; then
    echo "Error: Origin path does not exist"
    exit 1
fi

# Check if destination path exists, create if it doesn't
if [ ! -d "$destination_path" ]; then
    mkdir -p "$destination_path"
fi

# Move all files from origin to destination
mv "$origin_path"/* "$destination_path"

# Create new folders in destination
mkdir -p $destination_path + "/SourceCode/"
mkdir -p $destination_path + "/Documents/"

# Delete origin path
rm -rf "$origin_path"

# Create symbolic link from destination to origin
ln -s "$destination_path" "$origin_path"

echo "Operation completed successfully."