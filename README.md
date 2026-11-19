# Deploy TridaPad on Render

Thank you for choosing TridaPad. This repository helps you deploy [TridaPad](https://tridalabs.com) on [Render](https://render.com) in a few steps.

Along with TridaPad, it also deploys:
- **AgentSQL**, which lets you ask questions in plain language and get SQL and dashboards.
- **TridaPad MCP server**, which lets AI tools work with TridaPad.

## Deployment Options

| Option | Best for | Approximate cost |
|---|---|---|
| **Production-ready** (this branch: `production-ready`) | Teams in production, 10+ users | $266 / month |
| **Low-cost starter** ([`low-cost-starter` branch](https://github.com/tridalabs/tridapad-deploy-to-render/tree/low-cost-starter)) | Small teams, testing and evaluation | $44 / month |

Please note that the low-cost starter has no scheduler, so scheduled queries do not run there.

## What Gets Deployed

| Name | Plan | Size | Purpose |
|---|---|---|---|
| `tridapad` | Pro | 2 CPU, 4 GB | The TridaPad web application |
| `tridapad-worker` | Pro | 2 CPU, 4 GB | Runs queries, alerts and emails |
| `tridapad-scheduler` | Starter | 0.5 CPU, 512 MB | Starts scheduled queries and other timed jobs |
| `agentsql` | Standard | 1 CPU, 2 GB | AgentSQL |
| `tridapad-mcp` | Standard | 1 CPU, 2 GB | TridaPad MCP server |
| `tridapad-database` | Postgres `basic-1gb` | 0.5 CPU, 1 GB | Database for TridaPad and AgentSQL |
| `tridapad-redis` | Key Value Standard | 1 GB | Job queues and cache |

TridaPad and AgentSQL share one database and one Key Value instance. AgentSQL keeps its tables in a separate `agentsql` schema. Both the database and Key Value accept connections only from your other Render services.

### Cost

| Item | Monthly |
|---|---|
| TridaPad web and worker (Pro, 2 × $85) | $170 |
| TridaPad scheduler (Starter) | $7 |
| AgentSQL and MCP server (Standard, 2 × $25) | $50 |
| Key Value (Standard) | $20 |
| Postgres (`basic-1gb`) | $19 |
| **Total** | **about $266** |

These are list prices, excluding database storage and taxes. Prices may change, so please check [Render's pricing page](https://render.com/pricing) before you deploy.

## Deploy

Click the button below to deploy the production-ready configuration:

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/tridalabs/tridapad-deploy-to-render/tree/production-ready)

To keep costs low, you can use the [low-cost starter](https://render.com/deploy?repo=https://github.com/tridalabs/tridapad-deploy-to-render/tree/low-cost-starter) instead.

During setup, Render may ask for a few values. You can leave them empty for now and fill them in afterwards, as described below.

For a detailed guide, please see our [Render deployment documentation](https://docs.tridalabs.com/self-hosted/deploy-to-render/).

## After Deploying

Auto-deploy is turned off for every service. After you change a value, please open that service and select **Manual Deploy → Deploy latest commit**.

### Step 1: Copy your service addresses

In the Render dashboard, open `tridapad`, `agentsql` and `tridapad-mcp` one at a time, and copy the link shown under each service name. It looks like `https://tridapad-xxxx.onrender.com`, or your own domain if you have added one.

Please keep in mind:
- Copy the link under the service name, not the address in your browser's address bar.
- Do not add a `/` at the end of an address.

### Step 2: Fill in the settings

Open each service, go to **Environment**, enter the values below, and save.

| Service | Setting | Value | Example |
|---|---|---|---|
| `tridapad` | `TRIDAPAD_AGENTSQL_SERVICE_URL` | Your AgentSQL address | `https://agentsql-xxxx.onrender.com` |
| `tridapad-worker` | `TRIDAPAD_HOST` | Your TridaPad address | `https://tridapad-xxxx.onrender.com` |
| `agentsql` | `MCP_SERVER_URL` | Your MCP server address, followed by `/mcp` | `https://tridapad-mcp-xxxx.onrender.com/mcp` |
| `agentsql` | `CORS_ORIGINS` | Your TridaPad address, inside `["..."]` | `["https://tridapad-xxxx.onrender.com"]` |
| `agentsql` | `ANTHROPIC_API_KEY` | Your Anthropic API key | `sk-ant-...` |
| `tridapad-mcp` | `TRIDAPAD_URL` | Your TridaPad address | `https://tridapad-xxxx.onrender.com` |

A few helpful notes:
- `CORS_ORIGINS` must use the `["..."]` format. Otherwise, AgentSQL will not start.
- `TRIDAPAD_HOST` is used for links in alerts and emails.
- Please make sure to fill in `TRIDAPAD_AGENTSQL_SERVICE_URL`. If it is empty, TridaPad uses the AgentSQL service hosted by Tridalabs instead of yours.
- `TRIDAPAD_BASE_URL` on `agentsql` is not required. You may leave it empty.
- The MCP server uses each person's own TridaPad API key, so no shared key is needed.

When you are done, please redeploy `tridapad`, `tridapad-worker`, `agentsql` and `tridapad-mcp`.

### Step 3: Set up the databases (first deployment only)

1. Open the `tridapad` service, go to **Shell**, and run:
   ```shell
   render-tridapad create_db
   ```
2. Open the `agentsql` service, go to **Shell**, and run:
   ```shell
   render-agentsql create_db
   ```
3. Please allow about 5 minutes for the services to restart.

If you are moving an existing installation, please skip this step and follow [Moving from an Existing Installation](#moving-from-an-existing-installation).

### Step 4: Confirm everything works

| Open in your browser | You should see |
|---|---|
| Your TridaPad address | The TridaPad setup or login page |
| Your TridaPad address + `/ping` | `PONG.` |
| Your AgentSQL address + `/livez` | A response from AgentSQL |
| Your MCP server address + `/health` | A response from the MCP server |

## Optional Settings

### Email

Email is used for user invitations, password resets and alert notifications.

1. In the Render dashboard, open **Environment Groups** and select `tridapad-mail`.
2. Add the following settings:

   | Setting | Value |
   |---|---|
   | `TRIDAPAD_MAIL_SERVER` | Your SMTP server, for example `smtp.sendgrid.net` |
   | `TRIDAPAD_MAIL_PORT` | Usually `587` |
   | `TRIDAPAD_MAIL_USE_TLS` | `true` when using port 587 |
   | `TRIDAPAD_MAIL_USERNAME` | Your SMTP username |
   | `TRIDAPAD_MAIL_PASSWORD` | Your SMTP password |
   | `TRIDAPAD_MAIL_DEFAULT_SENDER` | The "From" email address |

3. Redeploy `tridapad`, `tridapad-worker` and `tridapad-scheduler`.

Popular email providers include [SendGrid](https://sendgrid.com/), [Amazon SES](https://aws.amazon.com/ses/) and [Mailgun](https://www.mailgun.com/).

### Google Login

1. Create OAuth credentials in the [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
2. Add this redirect URI, using your TridaPad address:
   `https://tridapad-xxxx.onrender.com/oauth/google_oauth2_callback`
3. In the Render dashboard, open **Environment Groups**, select `tridapad-oauth`, and add:
   - `TRIDAPAD_GOOGLE_CLIENT_ID`: your Google client ID
   - `TRIDAPAD_GOOGLE_CLIENT_SECRET`: your Google client secret
4. Redeploy `tridapad`.

Google login is enabled automatically once both settings are added.

### Custom Domain

1. Open the `tridapad` service and go to **Settings → Custom Domains**.
2. Add your domain, for example `pad.yourdomain.com`.
3. Update your DNS as Render instructs. Render provides the SSL certificate automatically.
4. Update the settings that contain your TridaPad address (`TRIDAPAD_HOST`, `CORS_ORIGINS` and `TRIDAPAD_URL`), then redeploy those services.
5. If you use Google login, please add the new redirect URI in the Google Cloud Console.

## Scaling

As your team grows, you can change any service's plan in the Render dashboard.

| Plan | CPU | Memory |
|---|---|---|
| Starter | 0.5 | 512 MB |
| Standard | 1 | 2 GB |
| Pro | 2 | 4 GB |
| Pro Plus | 4 | 8 GB |

Some helpful tips:
- The database is usually the first component that needs more capacity.
- To run more queries at once, add instances to `tridapad-worker`, or set `WORKERS_COUNT` on it (default: 2).
- Please note that a Key Value instance can be upgraded but cannot be downgraded later.

## Moving from an Existing Installation

### Step 1: Save your secret keys

Before you deploy, please copy these two values from the `.env` file on your current server:

```bash
grep TRIDAPAD_SECRET_KEY .env
grep TRIDAPAD_COOKIE_SECRET .env
```

This is important. `TRIDAPAD_SECRET_KEY` protects your saved data source credentials. If a different key is used, TridaPad cannot read them, and your data source connections will stop working.

### Step 2: Back up your database

```bash
pg_dump your_database > tridapad_backup.sql
```

### Step 3: Deploy with your keys

1. Click the **Deploy to Render** button.
2. Before clicking **Apply**, open the `tridapad-shared` environment group and replace the generated values with your own:
   - `TRIDAPAD_SECRET_KEY`
   - `TRIDAPAD_COOKIE_SECRET`
3. Click **Apply**.

### Step 4: Import your data

Please do not run `render-tridapad create_db`, because your backup already contains the tables.

The database accepts connections only from Render services, so please allow your computer temporarily:
1. Open `tridapad-database` in the Render dashboard, find its allowed IP addresses, and add your computer's IP address.
2. Copy the **External Database URL** and run:
   ```bash
   psql "<External Database URL>" < tridapad_backup.sql
   ```
3. Remove your IP address from the allowed list.

Next, run `render-agentsql create_db` in the `agentsql` service's Shell, and complete Steps 1, 2 and 4 of [After Deploying](#after-deploying).

### Step 5: Update your DNS

Point your domain to the new Render service, as described in [Custom Domain](#custom-domain).

## Troubleshooting

| Issue | What to check |
|---|---|
| Database connection errors | For a new installation, make sure `render-tridapad create_db` was run. Check that `tridapad-database` is available. |
| Queries do not run | Make sure `tridapad-worker` is running and review its logs. Check that `tridapad-redis` is available. |
| Scheduled queries or alerts do not run | Make sure `tridapad-scheduler` is running and review its logs. |
| Links in alerts or emails do not work | Set `TRIDAPAD_HOST` on `tridapad-worker` to your TridaPad address, then redeploy the worker. |
| AgentSQL does not start | Check that `CORS_ORIGINS` uses the `["..."]` format and that `MCP_SERVER_URL` ends in `/mcp`. |
| Chat does not respond | Check `TRIDAPAD_AGENTSQL_SERVICE_URL` on `tridapad` and `ANTHROPIC_API_KEY` on `agentsql`. |
| MCP server does not start | Check that `TRIDAPAD_URL` is set on `tridapad-mcp`. |
| Emails are not sent | Check the settings in `tridapad-mail`, confirm the sender address is verified with your provider, and review the `tridapad-worker` logs. |

## Support

We are happy to help. Please reach out through any of these:

- **Documentation**: https://docs.tridalabs.com/
- **Docker image**: https://hub.docker.com/r/tridalabs/tridapad
- **Website**: https://tridalabs.com
- **GitHub**: https://github.com/tridalabs/tridapad

## About TridaPad

TridaPad is a data analytics and visualization platform that helps anyone work with data:

- **Browser-based**: works entirely in your browser, with shareable links
- **Query editor**: write SQL and NoSQL queries with autocomplete
- **Visualizations**: build charts with drag-and-drop
- **Dashboards**: bring your visualizations together
- **Scheduled queries**: keep your data up to date automatically
- **Alerts**: get notified when your data changes
- **AI assistant**: ask questions in plain language with AgentSQL
- **35+ data sources**: PostgreSQL, MySQL, BigQuery, Redshift and more

## License

TridaPad is a proprietary data analytics platform available for free use via Docker Hub. While the source code is not publicly available, the application is free to deploy and use.

For commercial licensing, support or custom deployments, please contact us at https://tridalabs.com.
