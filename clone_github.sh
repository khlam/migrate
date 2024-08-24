#!/bin/bash

# Check if the text file with repo URLs is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <repo_list.txt>"
    exit 1
fi

# Create the output directory if it doesn't exist
output_dir="github_repos"
mkdir -p "$output_dir"

# Read each line in the file and clone the repository
while IFS= read -r repo; do
    # Skip empty lines or lines starting with a hash (#)
    if [ -z "$repo" ] || [[ $repo =~ ^# ]]; then
        continue
    fi

    # Extract repo name from URL
    repo_name=$(basename "$repo" .git)

    echo "Cloning $repo into $output_dir/$repo_name..."

    # Clone the repository with all branches and LFS files into the output directory
    git clone --mirror "$repo" "$output_dir/$repo_name"

    # Change to the repo directory
    cd "$output_dir/$repo_name" || exit

    # Fetch all LFS files
    git lfs fetch --all

    # Check out all branches
    for branch in $(git branch -r | grep -v '\->'); do
        git branch --track "${branch##origin/}" "$branch"
    done

    # Return to the root directory
    cd - > /dev/null

    echo "$repo_name cloned successfully into $output_dir."

done < "$1"
