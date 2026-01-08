FROM n8nio/n8n:latest

USER root

RUN apk add --no-cache ffmpeg python3 py3-pip \
  && pip3 install yt-dlp

USER node
