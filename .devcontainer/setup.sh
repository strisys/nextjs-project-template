#!/bin/bash
pwd
ls -la
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

chmod +x /usr/local/bin/pwsh

execute_script() {
    local script_name="$1"
    local full_path="$SCRIPT_DIR/$script_name"
    chmod +x "$full_path"
    echo "Executing script: $script_name"
    "$full_path"
    echo "Finished executing: $script_name"
}

# Execute scripts
execute_script "setup-pwsh.sh"
execute_script "setup-git.sh"
pip install -r "$SCRIPT_DIR/requirements-dev.txt"
execute_script "setup-sso-configure.sh"
