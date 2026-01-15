#!/bin/bash

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

			# If branch is empty (e.g. detached HEAD), try to get commit hash or generic name
			if [ -z "$branch" ]; then
				branch="(Detached HEAD)"
			fi

			# --- Header Output ---
			echo "=========================================="
			echo "# Git Repository: $dir"
			echo "# Branch:         $branch"
			# ---------------------

			# Loop through changes to generate commands
			echo "$changes" | while read -r line; do

				# Extract status (first 2 chars) and filename (from char 4 onwards)
				status="${line:0:2}"
				file="${line:3}"

				# Remove quotes if present
				file=$(echo "$file" | sed 's/^"//;s/"$//')

				# Construct full path
				fullpath="${dir}${file}"

				# Check if file is Deleted (D) or Modified/Untracked
				if [[ "$status" == *"D"* ]]; then
					echo "git rm \"$fullpath\""
				else
					echo "git add \"$fullpath\""
				fi
			done
		fi
	fi
done