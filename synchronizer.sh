#!/bin/bash

# GitHub repository details
REPO_OWNER="Ikechukwu-Patrick" # Replace with your GitHub username
REPO_NAME="Testing-User"        # Replace with your repository name
GITHUB_TOKEN="${GITHUB_TOKEN}"    # GitHub token passed by GitHub Actions

# GitHub API URLs
BASE_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}"
SECRETS_URL="${BASE_URL}/actions/secrets"

# Fetch the public key from GitHub for encrypting secrets
get_public_key() {
  curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$SECRETS_URL/public-key"
}

# Encrypt a secret using the public key
encrypt_secret() {
  local secret_value=$1
  local public_key=$2

  echo -n "$secret_value" | openssl rsautl -encrypt -pubin -inkey <(echo "$public_key" | base64 -d) | base64
}

# Add or update a secret on GitHub
add_or_update_secret() {
  local secret_name=$1
  local secret_value=$2
  local public_key=$3
  local key_id=$4

  encrypted_value=$(encrypt_secret "$secret_value" "$public_key")
  curl -X PUT -s \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"encrypted_value\":\"$encrypted_value\",\"key_id\":\"$key_id\"}" \
    "${SECRETS_URL}/${secret_name}" >/dev/null

  echo "Secret '${secret_name}' added/updated successfully."
}

# Fetch all existing secrets
fetch_existing_secrets() {
  curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$SECRETS_URL" | jq -r '.secrets[].name'
}

# Main function to sync secrets
sync_secrets() {
  # Fetch the public key
  public_key_data=$(get_public_key)
  public_key=$(echo "$public_key_data" | jq -r '.key')
  key_id=$(echo "$public_key_data" | jq -r '.key_id')

  if [ -z "$public_key" ] || [ -z "$key_id" ]; then
    echo "Failed to fetch public key from GitHub!"
    exit 1
  fi

  # Fetch existing secrets from GitHub
  existing_secrets=$(fetch_existing_secrets)

  # Find environment variables in your project
  echo "Scanning for environment variables in codebase..."
  all_env_vars=$(grep -r "export " . | awk -F'=' '{print $1}' | sed 's/export //g' | sort | uniq)

  for env_var in $all_env_vars; do
    # Skip if the secret already exists
    if echo "$existing_secrets" | grep -q "$env_var"; then
      echo "Secret '$env_var' already exists on GitHub. Skipping."
      continue
    fi

    # Read the value of the environment variable from the code
    env_value=$(grep -r "export ${env_var}=" . | head -n 1 | awk -F'=' '{print $2}' | tr -d '"')

    if [ -n "$env_value" ]; then
      echo "Adding/Updating secret: $env_var"
      add_or_update_secret "$env_var" "$env_value" "$public_key" "$key_id"
    fi
  done

  echo "Secrets synchronization complete."
}

# Run the sync
sync_secrets
