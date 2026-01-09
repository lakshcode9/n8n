# n8n Self-Hosted on Render (Free Forever Stack)

A complete guide to running **n8n** for free using Render + Supabase + UptimeRobot, with custom media processing capabilities.

## 🎯 Why This Setup?

Running n8n locally works, but it's not practical for 24/7 automation. This stack solves the common problems:

- **No data loss**: Workflows persist through restarts (external Postgres)
- **Always available**: UptimeRobot keeps the service awake
- **Custom capabilities**: Extended with ffmpeg, Python, and yt-dlp for media processing
- **Free tier**: Zero cost using free tiers of Render, Supabase, and UptimeRobot

## 📋 Prerequisites

Create free accounts on:
1. **[Render](https://render.com)** - Docker web service hosting
2. **[Supabase](https://supabase.com)** - Managed PostgreSQL database
3. **[UptimeRobot](https://uptimerobot.com)** - Service monitoring (prevents idle sleep)

## 🗄️ Step 1: Set Up Supabase Database

1. Log into Supabase → **New Project**
2. Set your database password (save this!)
3. Wait for project to finish provisioning
4. Go to **Project Settings → Database → Connection Info**
5. Note down the **Session Pooler** connection details:
   - Host: `aws-1-us-east-1.pooler.supabase.com` (or your region)
   - Port: `5432`
   - Database: `postgres`
   - User: `postgres.<your-project-id>`
   - Password: `<your-password>`

> **Note**: Use the **Session Pooler**, not the direct connection. It handles connection limits better.

## 🚀 Step 2: Deploy to Render

### Option A: Deploy via Blueprint (Recommended)

1. Fork this repository to your GitHub account
2. Log into Render → **New** → **Blueprint**
3. Connect your GitHub repository
4. Render will automatically read `render.yaml` and set up the service
5. The blueprint pre-configures:
   - Docker runtime with custom image
   - Port 5678
   - US-East region (matches Supabase)
   - Base environment variables

### Option B: Manual Deployment

1. Log into Render → **New** → **Web Service**
2. Select **Deploy from Docker**
3. Configure:
   - **Name**: `n8n` (or your choice)
   - **Region**: `Virginia (US East)` (match your Supabase region)
   - **Branch**: `main`
   - **Dockerfile Path**: `./Dockerfile`
   - **Docker Build Context**: `./`
4. Click **Create Web Service**

## 🔧 Step 3: Configure Environment Variables

In Render dashboard → Your service → **Environment** tab, add these variables:

### Database Configuration (Supabase)
```bash
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=aws-1-us-east-1.pooler.supabase.com
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=postgres
DB_POSTGRESDB_USER=postgres.<your-project-id>
DB_POSTGRESDB_PASSWORD=<your-supabase-password>
DB_POSTGRESDB_SSL=true
DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false
```

### n8n Base Configuration
```bash
N8N_HOST=<your-app>.onrender.com
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_EDITOR_BASE_URL=https://<your-app>.onrender.com
WEBHOOK_URL=https://<your-app>.onrender.com/
```

### Security & Features
```bash
N8N_ENCRYPTION_KEY=<generate-random-32-char-string>
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
N8N_RUNNERS_ENABLED=true
N8N_TRUSTED_PROXIES=0.0.0.0/0
```

> ⚠️ **CRITICAL**: The `N8N_ENCRYPTION_KEY` must NEVER change. Save it somewhere safe. If you lose it, you cannot decrypt existing credentials.

### Generate Encryption Key
```bash
# Linux/Mac/WSL
openssl rand -base64 32

# Or use any random string generator
```

## 🌐 Step 4: Custom Domain (Optional)

If you want to use your own domain like `n8n.yourdomain.com`:

1. In Render → Your service → **Settings** → **Custom Domain**
2. Add your domain (e.g., `n8n.yourdomain.com`)
3. Render will provide a CNAME target
4. In your DNS provider, add a CNAME record:
   ```
   Type: CNAME
   Name: n8n
   Value: <your-app>.onrender.com
   TTL: 3600
   ```
5. Wait for DNS propagation (5-30 minutes)
6. Update environment variables to match:
   ```bash
   N8N_HOST=n8n.yourdomain.com
   N8N_EDITOR_BASE_URL=https://n8n.yourdomain.com
   WEBHOOK_URL=https://n8n.yourdomain.com/
   ```
7. Redeploy the service

## ⏰ Step 5: Keep It Awake with UptimeRobot

Render free tier idles after 15 minutes of inactivity. UptimeRobot pings it every 5 minutes to prevent sleep.

1. Log into UptimeRobot → **Add New Monitor**
2. Configure:
   - **Monitor Type**: HTTP(s)
   - **Friendly Name**: `n8n keepalive`
   - **URL**: `https://<your-app>.onrender.com` (or your custom domain)
   - **Monitoring Interval**: 5 minutes
3. Click **Create Monitor**

Your n8n instance will now stay awake 24/7 on the free tier.

## 🎬 What's in the Custom Docker Image?

This setup uses a custom Dockerfile that extends the official n8n image with:

- **ffmpeg**: Video/audio processing and conversion
- **Python 3**: Runtime for Python-based nodes
- **yt-dlp**: Download videos from YouTube and 1000+ sites

This enables workflows that can:
- Download and process media files
- Convert audio/video formats
- Extract audio from videos
- Run Python scripts within workflows

## 📝 Verify Deployment

1. Open your n8n URL: `https://<your-app>.onrender.com`
2. First load may take 30-60 seconds (cold start)
3. Create your owner account
4. Test workflow persistence:
   - Create a simple workflow
   - Wait 20 minutes (let Render idle)
   - Refresh - workflow should still be there ✅

## 🔍 Troubleshooting

### Database Connection Errors
```
Database connection timed out
503 Database is not ready!
```
**Solution**: 
- Verify Supabase credentials are correct
- Ensure you're using the Session Pooler, not direct connection
- Check region match: Render service and Supabase should be in same region (US-East)

### Service Won't Start
- Check Render logs: Dashboard → Your service → Logs
- Verify all environment variables are set
- Ensure `N8N_ENCRYPTION_KEY` is set

### Workflows Lost After Restart
- Verify `DB_TYPE=postgresdb` is set
- Check Supabase connection credentials
- Look for database connection errors in logs

### SSL/TLS Errors
- Ensure `DB_POSTGRESDB_SSL=true`
- Set `DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false`

### Rate Limiting Issues
- Set `N8N_TRUSTED_PROXIES=0.0.0.0/0` to trust Render's proxy headers

## 🎯 Best Practices

1. **Backup Your Encryption Key**: Store `N8N_ENCRYPTION_KEY` in a password manager
2. **Use Session Pooler**: Direct Supabase connections have strict limits
3. **Monitor UptimeRobot**: Check it's running to prevent service sleep
4. **Set Data Retention**: Configure `EXECUTIONS_DATA_MAX_AGE=168` (7 days) to keep DB size manageable
5. **Enable Pruning**: Set `EXECUTIONS_DATA_PRUNE=true` to auto-clean old executions

## 📊 Expected Performance

- **Cold Start**: 30-60 seconds (first request after idle)
- **Warm Response**: <500ms
- **Database Latency**: ~20-50ms (same region)
- **Uptime**: 99.9%+ with UptimeRobot configured

## 🚨 Common Mistakes

1. ❌ Using wrong Supabase connection (use Session Pooler, not Transaction or Direct)
2. ❌ Forgetting to set `N8N_ENCRYPTION_KEY` before first run
3. ❌ Mismatching regions (Render in Oregon, Supabase in US-East)
4. ❌ Not setting up UptimeRobot → service sleeps
5. ❌ Typos in environment variables (double-check!)

## 📚 Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Render Docs](https://render.com/docs)
- [Supabase Docs](https://supabase.com/docs)
- [UptimeRobot Docs](https://uptimerobot.com/api/)

## 🤝 Contributing

Found a better way to do something? Open an issue or PR!

## 📄 License

This setup guide is provided as-is. n8n itself is licensed under the [Sustainable Use License](https://github.com/n8n-io/n8n/blob/master/LICENSE.md).

---

**Built with ❤️ for the n8n community**

*If this guide helped you, consider giving it a ⭐️*