#!/bin/bash

# Loop through all sub-directories
for dir in */; do
    # Check if the folder is a Git Repo (does it have a .git folder?)
    if [ -d "$dir/.git" ]; then
        echo "=========================================="
        echo "Checking: $dir"

        # Use subshell (...) to cd in, pull, and automatically return to original directory
        (cd "$dir" && git pull)
    else
        echo "Skipping: $dir (Not a git repo)"
    fi
done

echo "Script update completed."
exit 0
