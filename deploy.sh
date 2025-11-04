#!/bin/bash
set -e # This makes the script exit if any command fails

echo "Deployment script started..."

# 1. Pull the latest code from the main branch
# (This is run by the bot, but we do it again to be safe)
git pull origin main

# 2. Build the new Docker image
# (No sudo needed if you added your user to the 'docker' group)
echo "Building new Docker image..."
docker build -t myapp:latest .

# 3. Stop the old container
echo "Stopping old container..."
docker stop myapp || true

# 4. Remove the old container
echo "Removing old container..."
docker rm myapp || true

# 5. Run the new container
echo "Starting new container..."
docker run -d --name myapp -p 8080:5000 myapp:latest

echo "Deployment successful!"