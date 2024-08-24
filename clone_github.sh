#!/bin/bash

# Check if the text file with repo URLs is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <repo_list.txt>"
    exit 1
fi

# Load environment variables from the .env file
if [ -f "fetch_repos/.env" ]; then
    export $(grep -v '^#' fetch_repos/.env | xargs)
else
    echo "Error: .env file not found in fetch_repos/."
    exit 1
fi

# Ensure GITHUB_USERNAME is set
if [ -z "$GITHUB_USERNAME" ]; then
    echo "Error: GITHUB_USERNAME is not set in the .env file."
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

    # Extract owner and repo name from URL
    repo_url=$(basename "$repo" .git)
    owner=$(echo "$repo" | cut -d'/' -f4)
    repo_name=$(echo "$repo" | cut -d'/' -f5 | sed 's/.git$//')

    # Construct the SSH URL
    ssh_url="git@github.com:$owner/$repo_name.git"

    # Determine the target directory name
    if [ "$owner" != "$GITHUB_USERNAME" ]; then
        target_dir="$output_dir/$owner.$repo_name"
    else
        target_dir="$output_dir/$repo_name"
    fi

    echo "Cloning $ssh_url into $target_dir..."

    # Clone the repository with all branches into the output directory
    git clone --mirror "$ssh_url" "$target_dir"

    # Change to the repo directory
    cd "$target_dir" || exit

    # Check out all branches
    for branch in $(git branch -r | grep -v '\->'); do
        git branch --track "${branch##origin/}" "$branch"
    done

    # Return to the root directory
    cd - > /dev/null

    echo "$repo_name cloned successfully into $target_dir."

done < "$1"
