# Deploy TridaPad on Render

This repository can be used to deploy [TridaPad](https://tridalabs.com) on Render.

- It uses the [official TridaPad Docker image](https://hub.docker.com/r/tridalabs/tridapad) with an entrypoint script that customizes TridaPad for Render.
- It creates a Web Service on **Standard** plan for TridaPad and two [Background Workers](https://render.com/docs/background-workers) for job processing.
- [Render Databases](https://render.com/docs/databases) are used to spin up a fully managed PostgreSQL instance.
- It uses [Render Key Value](https://render.com/docs/key-value) (managed Redis) for caching and asynchronous job queues.
- It provides template [environment groups](https://render.com/docs/yaml-spec#environment-groups) for optionally setting up mailing and OAuth in TridaPad.

## Choose Your Deployment Option

### 🚀 Production-Ready (This Branch: `production-ready`)
**Starting at $35/month** - Recommended for:
- Production workloads
- Medium to large teams (10+ users)
- Higher traffic applications
- Businesses requiring better performance from day one

Uses Standard plans with separate worker and scheduler services.

### 🎯 Low-Cost Starter (`low-cost-starter` branch)
**Starting at $14-21/month** - Perfect for:
- Small teams (1-10 users)
- Testing and development
- Low-traffic deployments
- Budget-conscious startups

[Switch to low-cost-starter branch](https://github.com/tridalabs/tridapad-deploy-to-render/tree/low-cost-starter) for the budget-friendly configuration with easy upgrade paths.

## Deployment

### One Click

Use the button below to deploy TridaPad on Render with the **production-ready configuration**.

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/tridalabs/tridapad-deploy-to-render/tree/production-ready)

> **Want to minimize costs?** Use the [low-cost-starter deployment](https://render.com/deploy?repo=https://github.com/tridalabs/tridapad-deploy-to-render/tree/low-cost-starter) ($14-21/month)

Then, in Render Shell of the `tridapad` web service execute the following statement:

```shell
$ render-tridapad create_db
```

### Manual

See the complete deployment guide at https://docs.tridalabs.com/self-hosted/deploy-to-render/

If you need help, visit https://tridalabs.com or contact support.

## What Gets Deployed

The deployment will create:

- **Web Service** (Standard) - Main TridaPad application server
- **Worker** (Standard) - Background worker for query execution
- **Scheduler** (Starter) - Handles scheduled queries and periodic tasks
- **PostgreSQL Database** (`tridapad-database`, Starter) - Managed database with automatic backups
- **Key Value** (`tridapad-redis`, Starter) - Managed Redis for caching and job queues with disk-backed persistence

### Cost

Starting at **~$35/month** for a production-ready setup:
- Web Service (Standard): $7/month
- Worker (Standard): $7/month
- Scheduler (Starter): $7/month
- PostgreSQL (Starter): $7/month
- Key Value (Starter): $7/month

> **Note:** A free tier is available for testing. Change `plan: starter` to `plan: free` in `render.yaml` for the Key Value service. Free tier has limited storage and doesn't persist data to disk.

## Configuration

### Required Setup

After deployment, you **must** initialize the database:

1. Go to your `tridapad` web service in Render dashboard
2. Open the **Shell** tab
3. Run: `render-tridapad create_db`
4. Wait for initialization to complete (~1-2 minutes)
5. **Important:** Wait an additional 5 minutes for the service to fully restart and apply changes before accessing the web UI

### Optional: Email Configuration

To enable email functionality (user invites, alerts, password resets):

1. In Render dashboard, go to Environment tab
2. Edit the `tridapad-mail` environment group
3. Uncomment and fill in your SMTP credentials:
   - `TRIDAPAD_MAIL_SERVER`: Your SMTP server (e.g., smtp.sendgrid.net)
   - `TRIDAPAD_MAIL_PORT`: SMTP port (typically 587)
   - `TRIDAPAD_MAIL_USERNAME`: SMTP username
   - `TRIDAPAD_MAIL_PASSWORD`: SMTP password
   - `TRIDAPAD_MAIL_DEFAULT_SENDER`: From email address

**Recommended providers:**
- [SendGrid](https://sendgrid.com/) - 100 free emails/day
- [Amazon SES](https://aws.amazon.com/ses/) - Cost-effective for high volume
- [Mailgun](https://www.mailgun.com/) - Developer-friendly

### Optional: Google OAuth

To enable Google OAuth login:

1. Create OAuth credentials in [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Add authorized redirect URI: `https://your-service.onrender.com/oauth/google_callback`
3. In Render dashboard, edit `tridapad-oauth` environment group
4. Uncomment and fill in:
   - `TRIDAPAD_GOOGLE_CLIENT_ID`: Your Google client ID
   - `TRIDAPAD_GOOGLE_CLIENT_SECRET`: Your Google client secret
   - `TRIDAPAD_GOOGLE_OAUTH_ENABLED`: Set to `true`

## Scaling

### Vertical Scaling
Upgrade individual services to larger instance types in Render dashboard:
- Standard Plus (1GB RAM): $15/month
- Pro (2GB RAM): $25/month
- Pro Plus (4GB RAM): $65/month

### Horizontal Scaling
Increase the number of worker instances to handle more concurrent queries:
1. Go to your worker service
2. Adjust instance count
3. Costs scale linearly

## Custom Domain

1. Go to your web service settings
2. Navigate to **Custom Domains**
3. Add your domain (e.g., `pad.yourdomain.com`)
4. Configure DNS as instructed
5. Render automatically provisions SSL certificates

## Migrating from Self-Hosted

If you're migrating from an existing TridaPad installation and would like to get all the database connections details:

### Step 1: Get Your Existing Secret Keys (BEFORE Deploying)

⚠️ **CRITICAL:** You **MUST** preserve your existing secret keys before deploying to Render.

From your self-hosted server, retrieve these values from your `.env` file:
```bash
# On your EC2/self-hosted server
grep TRIDAPAD_SECRET_KEY .env
grep TRIDAPAD_COOKIE_SECRET .env
```

Copy these exact values - you'll need them in the next step.

**Why this matters:**
- `TRIDAPAD_SECRET_KEY` encrypts sensitive data in your database (data source credentials, API keys)
- If you use a different key, TridaPad **cannot decrypt** existing data sources
- All your configured database connections will be **permanently broken**

### Step 2: Backup Your Existing Self-hosted TridaPad Database

```bash
pg_dump your_database > tridapad_backup.sql
```

### Step 3: Deploy to Render with Your Keys

1. Click the "Deploy to Render" button
2. **BEFORE clicking "Apply"**, edit the `tridapad-shared` environment group
3. **Replace** the auto-generated values:
   - Delete the generated `TRIDAPAD_SECRET_KEY` value
   - Paste your **existing** `TRIDAPAD_SECRET_KEY` from Step 1
   - Delete the generated `TRIDAPAD_COOKIE_SECRET` value  
   - Paste your **existing** `TRIDAPAD_COOKIE_SECRET` from Step 1
4. Now click "Apply" to deploy

### Step 4: Import Your Data

**Do NOT initialize the database** - your backup already has the schema.

Get your Render PostgreSQL external connection string from the dashboard, then:
```bash
psql "postgresql://user:pass@host/database" < tridapad_backup.sql
```

### Step 5: Update DNS

Point your domain to your new Render service URL.

## Troubleshooting

### Database Connection Errors
- Ensure `render-tridapad create_db` was run
- Check that `TRIDAPAD_DATABASE_URL` is set correctly
- Verify database service is running

### Workers Not Processing Queries
- Check Key Value service is running and connected
- Verify `TRIDAPAD_REDIS_URL` environment variable is set correctly
- Verify `QUEUES` environment variable is set
- Review worker logs for errors

### Email Not Sending
- Verify all SMTP credentials are correct
- Check that `TRIDAPAD_MAIL_DEFAULT_SENDER` is a verified sender
- Review web service logs for SMTP errors

## Support

- **Documentation**: https://docs.tridalabs.com/
- **Docker Image**: https://hub.docker.com/r/tridalabs/tridapad
- **Community**: https://tridalabs.com
- **GitHub**: https://github.com/tridalabs/tridapad

## About TridaPad

TridaPad is a powerful data analytics and visualization platform designed to enable anyone to harness the power of data. It features:

- **Browser-based** - Everything in your browser with shareable URLs
- **Query Editor** - Compose SQL and NoSQL queries with autocomplete
- **Visualizations** - Beautiful charts with drag-and-drop
- **Dashboards** - Combine visualizations into comprehensive dashboards
- **Scheduled Queries** - Automatic data refreshes
- **Alerts** - Get notified when data changes
- **35+ Data Sources** - PostgreSQL, MySQL, BigQuery, Redshift, and more

## License

TridaPad is a proprietary data analytics platform available for free use via Docker Hub. While the source code is not publicly available, the application is free to deploy and use.

For commercial licensing, support, or custom deployments, contact us at https://tridalabs.com.

---

**Ready to deploy?** Click the Deploy to Render button above! 🚀
