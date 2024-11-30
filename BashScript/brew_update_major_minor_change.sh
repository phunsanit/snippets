#!/bin/bash

# https://en.wikipedia.org/wiki/Software_versioning
# Function to compare versions
version_compare() {
    local IFS=.
    local version1=($1) version2=($2)
    
    # Compare major and minor versions only
    for ((i=0; i<2; i++)); do
        if [ "${version1[$i]:-0}" -gt "${version2[$i]:-0}" ]; then
            return 1
        elif [ "${version1[$i]:-0}" -lt "${version2[$i]:-0}" ]; then
            return 2
        fi
    done
    return 0
}

echo "Checking for updates..."

# Get list of outdated packages with versions
brew outdated --verbose | while read -r line; do
    if [[ $line =~ (.*)[[:space:]]([0-9]+\.[0-9]+\.[0-9]+).*[[:space:]]([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        package="${BASH_REMATCH[1]}"
        current="${BASH_REMATCH[2]}"
        latest="${BASH_REMATCH[3]}"
        
        # Compare versions
        version_compare "$current" "$latest"
        result=$?
        
        if [ $result -eq 2 ]; then
            echo "Upgrading $package from $current to $latest"
            brew upgrade "$package"
        else
            echo "Skipping $package (no major/minor version change)"
        fi
    fi
done

echo "Update check complete!"