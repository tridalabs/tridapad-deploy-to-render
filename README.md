# Deploy TridaPad on Render

This repository can be used to deploy [TridaPad](https://tridalabs.com) on Render.

- It uses the [official TridaPad Docker image](https://hub.docker.com/r/tridalabs/tridapad) with an entrypoint script that customizes TridaPad for Render.
- It creates a Web Service and Background Worker for job processing.
- [Render Databases](https://render.com/docs/databases) are used to spin up a fully managed PostgreSQL instance.
- It uses [Render Key Value](https://render.com/docs/key-value) (managed Redis) for caching and asynchronous job queues.
- It provides template [environment groups](https://render.com/docs/yaml-spec#environment-groups) for optionally setting up mailing and OAuth in TridaPad.

## Choose Your Deployment Option

### 🎯 Low-Cost Starter (This Branch: `low-cost-starter`)
**Starting at $14-21/month** - Perfect for:
- Small teams (1-10 users)
- Testing and development
- Low-traffic deployments
- Budget-conscious startups

**Easily upgradable** as your needs grow.

### 🚀 Production-Ready (`production-ready` branch)
**Starting at $35/month** - Recommended for:
- Medium to large teams
- Production workloads
- Higher traffic applications
- Businesses requiring better performance from day one

[Switch to production-ready branch](https://github.com/tridalabs/tridapad-deploy-to-render/tree/production-ready) for the production configuration.

## Deployment

### One Click

Use the button below to deploy TridaPad on Render with the **low-cost starter configuration**.

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/tridalabs/tridapad-deploy-to-render/tree/low-cost-starter)

> **Want the production-ready setup?** Use the [production-ready deployment](https://render.com/deploy?repo=https://github.com/tridalabs/tridapad-deploy-to-render/tree/production-ready)

Then, in Render Shell of the `tridapad` web service execute the following statement:

```shell
$ render-tridapad create_db
```

### Manual

See the complete deployment guide at https://docs.tridalabs.com/self-hosted/deploy-to-render/

If you need help, visit https://tridalabs.com or contact support.

## What Gets Deployed

The deployment will create:

- **Web Service** (Starter) - Main TridaPad application server (512MB RAM, 0.5 CPU)
- **Worker + Scheduler** (Starter) - Combined background worker for all async jobs and scheduling (512MB RAM, 0.5 CPU)
- **PostgreSQL Database** - Managed database with automatic backups
- **Key Value** (Free) - Managed Redis for caching and job queues (100MB, no persistence)

### Cost Breakdown

#### Minimal Cost Setup (Current Configuration)
**Starting at $14/month** - Great for small teams, testing, and low-traffic deployments:

| Service | Plan | Specs | Cost |
|---------|------|-------|------|
| Web Service | Starter | 512MB RAM, 0.5 CPU | $7/month |
| Worker + Scheduler | Starter | 512MB RAM, 0.5 CPU | $7/month |
| PostgreSQL | Default | Render's default plan | Varies* |
| Redis | Free | 100MB, no persistence | FREE |

**Total: ~$14-21/month** (varies based on database plan selected)

*Database plan will be selected during deployment based on Render's current offerings.

#### Mid-Tier Setup
**Better for growing teams with moderate traffic:**

| Service | Plan | Specs | Cost |
|---------|------|-------|------|
| Web Service | Standard | 2GB RAM, 1 CPU | $25/month |
| Worker | Standard | 2GB RAM, 1 CPU | $25/month |
| PostgreSQL | Upgrade as needed | Varies | $7-20/month |
| Redis | Starter | 1GB storage, persistence | $7/month |

**Total: ~$64-77/month**

#### Production Setup
**High-traffic deployments with dedicated services:**

| Service | Plan | Specs | Cost |
|---------|------|-------|------|
| Web Service | Pro | 4GB RAM, 2 CPU | $85/month |
| Worker | Standard | 2GB RAM, 1 CPU | $25/month |
| Scheduler (separate) | Standard | 2GB RAM, 1 CPU | $25/month |
| PostgreSQL | Standard | 10GB storage, 4GB RAM | $20/month |
| Redis | Standard | 5GB storage | $20/month |

**Total: ~$175/month**

### Performance Upgrade Path

Start with the minimal setup and upgrade components as needed:

1. **First bottleneck (10-20 users)**: Upgrade Web Service to Standard ($25/mo) for better response times
2. **Heavy queries**: Upgrade Worker to Standard ($25/mo) for faster background processing
3. **Data persistence**: Upgrade Redis from Free to Starter ($7/mo) for persistent caching
4. **Growing data**: Upgrade PostgreSQL to Standard ($20/mo) when approaching 1GB storage
5. **High traffic**: Split worker into separate Worker + Scheduler services on Standard plans

> **Note:** You can upgrade/downgrade any service independently through the Render dashboard. Changes take effect immediately with minimal downtime.

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
