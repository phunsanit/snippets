#!/bin/bash

# Store the current path (for later use)
current_root=$(pwd)

# Loop through all sub-directories
for dir in */; do
	# Check if the directory is a Git repository
	if [ -d "$dir/.git" ]; then

		# Capture git status
		changes=$(cd "$dir" && git status --porcelain)

		# Process only if there are changes
		if [ -n "$changes" ]; then

			# Get current branch name
			# Note: git branch --show-current works on git version 2.22+
			branch=$(cd "$dir" && git branch --show-current)

			# If branch is empty (e.g. detached HEAD), try to set a fallback name
			if [ -z "$branch" ]; then branch="(Detached HEAD)"; fi

			# Create Full Path for the cd command (remove trailing slash from dir)
			repo_full_path="${current_root}/${dir%/}"

			# --- Header Output ---
			echo "=========================================="
			# Using printf to align columns perfectly
			# %-16s sets a fixed width of 16 characters for the label
			printf "# %-16s cd \"%s\"\n" "Path:" "$repo_full_path"
			printf "# %-16s %s\n"    "Git Repository:" "$dir"
			printf "# %-16s %s\n"    "Branch:" "$branch"
			# ---------------------

			# Loop through changes to generate commands
			echo "$changes" | while read -r line; do

				# Extract status (first 2 chars) and filename (from char 4 onwards)
				status="${line:0:2}"
				file="${line:3}"

				# Remove quotes if present
				file=$(echo "$file" | sed 's/^"//;s/"$//')

				# Use the filename directly since we cd into the directory
				fullpath="$file"

				# Check if file is Deleted (D) or Modified/Untracked
				if [[ "$status" == *"D"* ]]; then
					echo "git rm \"$fullpath\""
				else
					echo "git add \"$fullpath\""
				fi
			done

			# (Optional) Uncomment below if you want to cd back after each block
			# echo "cd \"$current_root\""
		fi
	fi
done