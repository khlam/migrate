#!/bin/bash

# Load environment variables from the .env file
if [ -f "fetch_repos/.env" ]; then
    export $(grep -v '^#' fetch_repos/.env | xargs)
else
    echo "Error: .env file not found in fetch_repos/."
    exit 1
fi

# Ensure required variables are set
if [ -z "$GITEA_URL" ] || [ -z "$GITEA_ORG" ] || [ -z "$GITEA_USER" ]; then
    echo "Error: GITEA_URL, GITEA_ORG, or GITEA_USER is not set in the .env file."
    exit 1
fi

# Directory containing the repositories
repos_dir="github_repos"

# Check if the directory exists
if [ ! -d "$repos_dir" ]; then
    echo "Error: Directory $repos_dir does not exist."
    exit 1
fi

# Loop through each repository in the directory
for repo_path in "$repos_dir"/*; do
    if [ -d "$repo_path" ]; then
        # Get the repository name from the directory name
        repo_name=$(basename "$repo_path")

        echo "Processing $repo_name..."
        echo "$GITEA_URL"

        # Navigate to the local repository
        cd "$repo_path" || exit

        # Check if the 'gitea' remote already exists
        if git remote get-url gitea &>/dev/null; then
            echo "Remote 'gitea' already exists for $repo_name."
        else
            # Add the new Gitea remote
            git remote add gitea "$GITEA_URL/$GITEA_ORG/$repo_name.git"
        fi

        # Push all branches to the new Gitea repository
        git push gitea --all

        # Push all tags to the new Gitea repository
        git push gitea --tags

        # Return to the root directory
        cd - > /dev/null

        echo "$repo_name has been pushed to Gitea."
    fi
done
