FROM node:20-bookworm-slim

# Install system dependencies
RUN apt-get update \
  && apt-get install -y ffmpeg python3 python3-pip ca-certificates curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install yt-dlp
RUN pip3 install --no-cache-dir yt-dlp

# Install n8n
RUN npm install -g n8n

# Create n8n user
RUN useradd -m n8n
USER n8n

# n8n environment
ENV N8N_PORT=5678
EXPOSE 5678

CMD ["n8n", "start"]
