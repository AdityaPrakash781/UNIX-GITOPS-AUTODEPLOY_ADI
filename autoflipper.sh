#!/bin/bash

# --- CONFIGURATION ---
# !! UPDATE THIS PATH !!
# This is the full path to your USP_MiniProject folder
REPO_DIR="C:\Users\adipr\OneDrive\Documents\Unix-gitops-autodeploy\USP_MiniProject"

# ---------------------

echo "Starting Auto-Flipper Bot... (Press Ctrl+C to stop)"

# Loop forever
while true; do
    echo "--------------------------------"
    echo "Running new cycle at $(date)"
    
    # Go into the repo directory
    cd $REPO_DIR
    
    # Sync with the remote repo first
    echo "Pulling latest changes..."
    git pull

    LIVE_CONFIG="config.json"
    
    # Check if the live config contains "Standby"
    if grep -q '"theme_name": "Standby"' $LIVE_CONFIG; then
      # It's currently "Standby", so switch to "Active"
      echo "Current state is STANDBY. Toggling to ACTIVE..."
      cp config.active.json $LIVE_CONFIG
      COMMIT_MSG="BOT: Activating AI Core"

    else
      # It's currently "Active", so switch back to "Standby"
      echo "Current state is ACTIVE. Toggling back to STANDBY..."
      cp config.standby.json $LIVE_CONFIG
      COMMIT_MSG="BOT: Resetting to Standby"
    fi
    
    # Push the change
    echo "Committing and pushing change..."
    git add $LIVE_CONFIG
    git commit -m "$COMMIT_MSG"
    git push origin main
    
    echo "Push successful. GitOps pipeline triggered."
    echo "Waiting 60 seconds before next cycle..."
    sleep 60

done