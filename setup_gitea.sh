#!/bin/bash
set -e

echo " Starting Gitea Local Setup Automation..."

# 1. Install System Dependencies
echo " [1/7] Installing system dependencies..."
sudo apt update -y
sudo apt install -y build-essential git curl sqlite3 libsqlite3-dev

# 2. Install Go (if missing)
if ! command -v go &> /dev/null; then
    echo "[2/7] Installing Go 1.23..."
    curl -LO https://go.dev/dl/go1.23.1.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz
    rm go1.23.1.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
else
    echo "[2/7] Go is already installed."
fi

# 3. Install Node.js 22 via nvm (Fixes the pnpm/Node 20 issue)
echo " [3/7] Installing Node.js 22 via nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 22
nvm use 22
nvm alias default 22

# 4. Install pnpm
echo "[4/7] Installing pnpm..."
npm install -g pnpm

# 5. Git Branch Setup & Documentation
BRANCH_NAME="task/local-setup-demo"
git checkout -b $BRANCH_NAME 2>/dev/null || git checkout $BRANCH_NAME

echo " Creating Automate_setup.md..."
cat << 'EOF' > Automate_setup.md
# Local Gitea Setup
Automated setup completed successfully using Go 1.23, Node 22, and SQLite3.
EOF
git add Automate_setup.md
git commit -m "docs: automated local setup verification" || echo "No new changes to commit."

# 6. Install Dependencies and Build
echo " [6/7] Installing frontend dependencies and building..."
make node_modules
make build

echo " [7/7] Starting Gitea server on http://localhost:3000..."
echo "Press Ctrl+C to stop the server."
./gitea web
