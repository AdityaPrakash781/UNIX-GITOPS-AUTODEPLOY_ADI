# Unix GitOps Auto-Deployment Simulator

A complete, self-contained simulation of a CI/CD pipeline using GitOps, Docker, and Flask.

![Python](https://img.shields.io/badge/Python-3.9-3776AB?logo=python)
![Flask](https://img.shields.io/badge/Flask-2.0-000000?logo=flask)
![Docker](https://img.shields.io/badge/Docker-20.10-2496ED?logo=docker)
![Shell Script](https://img.shields.io/badge/Shell_Script-Bash-4EAA25?logo=gnu-bash)
![GitOps](https://img.shields.io/badge/GitOps-Pipeline-F05032?logo=git)

---

## 🚀 Overview

This project is a **living demonstration of a complete GitOps workflow**. It creates a "closed loop" system where:

1.  A **Bot** automatically commits and pushes configuration changes.
2.  A **Webhook Server** detects the push and triggers a deployment.
3.  A **Deploy Script** automatically builds and redeploys a Dockerized application.

The entire cycle is automated, allowing you to watch the GitOps pipeline in action, triggering a new deployment every 60 seconds.

## ⚙️ How It Works: The "Closed Loop"

Here is the entire automated sequence:

1.  **Trigger:** The `auto-flipper-bot.sh` script (acting as a developer) runs. It changes the `config.json` from "Standby" to "Active" (or vice-versa) and `git push`es the commit to this repository.
2.  **Notify:** GitHub (or your Git provider) sees the new push and sends a **webhook** to your server.
3.  **Receive:** The `webhook-server.py` (running on **port 5001**) receives this webhook.
4.  **Deploy:** The webhook server executes the `deploy.sh` script.
5.  **Update:** The `deploy.sh` script pulls the latest code, builds a new `myapp:latest` Docker image, stops the old container, and starts the new one.
6.  **Result:** The main `app.py` is now live on **port 8080**, serving the new `config.json` file.
7.  **Repeat:** 60 seconds later, the bot runs again, and the cycle repeats.

## 📦 Project Components

### 1. The Main Application (The "Payload")

* `app.py`: The main Flask web application. It reads `config.json` and displays a status page.
* `Dockerfile`: Builds the `app.py` into a container.
* `index.html` (in `templates/`): The HTML page rendered by `app.py`.
* `requirements.txt`: Python dependencies for the main app (just `Flask`).

### 2. The GitOps Pipeline (The "Engine")

* `webhook-server.py`: A separate, lightweight Flask server that listens for webhooks on `/webhook` (port 5001). Its only job is to trigger the deployment script.
* `deploy.sh`: The core deployment script. It pulls the latest code, builds the Docker image, and restarts the container.

### 3. The Simulator (The "Trigger")

* `auto-flipper-bot.sh`: A shell script that simulates a developer. It runs in an infinite loop, toggling the configuration and pushing the change every 60 seconds.
* `config.active.json`: Config template for the "Active" state.
* `config.standby.json`: Config template for the "Standby" state.

## 🛠️ How to Set Up and Run

### Prerequisites

* A Unix-based server (e.g., Linux, Raspberry Pi OS)
* Docker & Docker Compose
* Python 3 & `pip`
* `git`

### Step 1: Server Setup (Run on your Server)

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd USP_MiniProject
    ```

2.  **Create `requirements.txt`:**
    ```bash
    echo "Flask" > requirements.txt
    ```

3.  **Make scripts executable:**
    ```bash
    chmod +x deploy.sh
    chmod +x auto-flipper-bot.sh
    ```

4.  **Run the Webhook Server (the Pipeline Engine):**
    ```bash
    # (Optional) Run in a screen or tmux session to keep it alive
    python3 webhook-server.py
    ```
    This will start the server on `http://<your-server-ip>:5001`.

5.  **Configure GitHub Webhook:**
    * Go to your repository's **Settings > Webhooks**.
    * Add a new webhook.
    * **Payload URL:** `http://<your-server-ip>:5001/webhook`
    * **Content type:** `application/json`
    * Leave the secret blank.
    * Save the webhook.

### Step 2: First Manual Deployment (Run on your Server)

Before the bot can run, the application needs to be running.

```bash
# Run the deploy script manually the first time
./deploy.sh
```
You should now be able to visit http://<your-server-ip>:8080 and see the application running.

### Step 3: Start the Bot (The "Trigger")

1.  **IMPORTANT: Edit the bot script.** The `auto-flipper-bot.sh` needs to know the *full path* to its directory.
    * Open `auto-flipper-bot.sh` with a text editor.
    * Change this line to the **full absolute path** of your project folder:

    ```bash
    # !! UPDATE THIS PATH !!
    REPO_DIR="/home/username/USP_MiniProject" 
    ```

2.  **Run the bot:**
    ```bash
    # (Optional) Run in a screen or tmux session
    ./auto-flipper-bot.sh
    ```

### Step 4: Watch the Magic!

You're all set!

1.  Watch the terminal running `auto-flipper-bot.sh`. You'll see it commit and push every 60 seconds.
2.  Watch the terminal running `webhook-server.py`. You'll see it receive the webhook and log the deployment.
3.  Refresh your browser at `http://<your-server-ip>:8080`. You will see the content flip between "AWAITING DEPLOYMENT" and "DEPLOYMENT IN PROGRESS!" every minute.
