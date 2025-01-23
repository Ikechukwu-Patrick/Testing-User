# GitHub repository details
REPO_OWNER="your-username-or-org"  # Replace with your username or org name
REPO_NAME="your-repo-name"         # Replace with your repo name

# GitHub API URLs
BASE_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}"
SECRETS_URL="${BASE_URL}/actions/secrets"

# Fetch the public key for encrypting secrets
get_public_key() {
  curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$SECRETS_URL/public-key"
}

# Add or update a secret on GitHub
add_or_update_secret() {
  ...
  curl -X PUT -s \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"encrypted_value\":\"$encrypted_value\",\"key_id\":\"$key_id\"}" \
    "${SECRETS_URL}/${secret_name}" >/dev/null
  ...
}
