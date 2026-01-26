echo "CLI_REPO_NAME : ${CLI_REPO_NAME}"
echo "CLI_REPO_DIR : ${CLI_REPO_DIR}"
echo "CLI_REPO_MAPPING_DIR : ${CLI_REPO_MAPPING_DIR}"
echo ""
echo "Show repository content with BASH container."
docker run -ti --rm \
    -v ${CLI_REPO_MAPPING_DIR}:/app \
    -w /app \
    bash -c "ls -al"
