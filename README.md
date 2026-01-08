# n8n Self-Hosted on Render

This repository contains the setup for self-hosting [n8n](https://n8n.io/) on Render with custom dependencies.

## Overview

n8n is a powerful workflow automation tool that lets you connect different services and automate tasks. This setup deploys n8n on Render with additional tools for media processing.

## Custom Dockerfile

The Dockerfile extends the official n8n image with:
- **ffmpeg**: For video/audio processing
- **Python 3**: Runtime for Python-based automation
- **yt-dlp**: YouTube and video download capabilities

## Deployment on Render

### Prerequisites
- A [Render](https://render.com/) account
- A PostgreSQL database (recommended for production)

### Environment Variables

Configure these in your Render web service:

```
# Database (recommended)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=<your-postgres-host>
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=<database-name>
DB_POSTGRESDB_USER=<database-user>
DB_POSTGRESDB_PASSWORD=<database-password>

# n8n Configuration
N8N_HOST=<your-app-url>.onrender.com
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://<your-app-url>.onrender.com/

# Basic Auth (optional)
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=<username>
N8N_BASIC_AUTH_PASSWORD=<password>

# Encryption Key (generate a random string)
N8N_ENCRYPTION_KEY=<your-encryption-key>
```

### Deployment Steps

1. Fork or push this repository to GitHub
2. Connect your GitHub repository to Render
3. Create a new Web Service on Render
4. Select "Docker" as the environment
5. Configure environment variables
6. Deploy!

## Features

This setup enables workflows that can:
- Download and process videos from YouTube and other platforms
- Convert and manipulate audio/video files
- Run Python scripts within workflows
- Connect to 400+ services and APIs

## Local Development

To run locally:

```bash
docker build -t n8n-custom .
docker run -p 5678:5678 n8n-custom
```

Access n8n at `http://localhost:5678`

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Render Documentation](https://render.com/docs)