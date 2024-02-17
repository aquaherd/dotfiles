# jfrog artifactory
if command -v jf > /dev/null; then
    eval "$(JFROG_CLI_AVOID_NEW_VERSION_WARNING=TRUE jf completion bash)"
fi

