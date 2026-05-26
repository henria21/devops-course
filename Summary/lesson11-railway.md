# Lesson 11 — Railway (PaaS Deployment)
> Source: `Class 11 - Railway.pptx` (15 slides)

---

## What is Railway?

Railway is a modern **Platform-as-a-Service (PaaS)** that allows developers to deploy applications quickly **without managing infrastructure**.

### Key Benefits
- Simple deployment directly from a GitHub repository
- Built-in CI/CD — push to GitHub → auto-deploy
- Free trial available
- Supports multiple languages: Node.js, Go, Python, and more
- Managed infrastructure, automatic builds, environment variable management
- Database provisioning (PostgreSQL, MySQL, Redis)

---

## What Railway Provides

| Feature | Description |
|---|---|
| Managed infrastructure | No servers to configure or maintain |
| Automatic builds | Detects project type and builds automatically |
| Auto-deployment | Every push to GitHub triggers a new deploy |
| Environment variables | Secure variable management via dashboard |
| Database services | PostgreSQL, MySQL, Redis — one-click add |
| Custom domains | Default domain provided; attach your own |
| Logs & monitoring | Real-time logs, deployment history, metrics |

---

## Prerequisites

Before starting:
- GitHub account
- Backend service repository (Node.js / Go / Python)
- Railway account at https://railway.app

---

## Deploying from GitHub

### Step 1: Login and Create Project
1. Go to Railway dashboard
2. Click **"New Project"**
3. Select **"Deploy from GitHub Repo"**
4. Connect your GitHub account
5. Choose your repository

### Step 2: Automatic Build
Railway will automatically:
1. Detect the project type (Python, Node.js, etc.)
2. Install dependencies (`requirements.txt`, `package.json`)
3. Build the project
4. Start the service using `Procfile` or default command

---

## Preparing Your Backend (Python)

### Important Requirements
- App must listen on the `PORT` **environment variable** (Railway injects it)
- Use a production-ready server: `uvicorn` or `gunicorn`

### Example `Procfile`
```
web: uvicorn app:app --host 0.0.0.0 --port $PORT
```

### Example Python structure
```
my-app/
├── app.py
├── requirements.txt
└── Procfile
```

---

## Environment Variables

Add variables in the Railway dashboard:

```
DATABASE_URL    = postgres://...
API_KEYS        = my-secret-key
SECRET_KEYS     = another-secret
PORT            = (auto-injected by Railway)
```

Variables are securely stored and injected at runtime — never in code.

---

## Using Databases

Railway makes adding databases easy:
1. Click **"Add Service"** → choose PostgreSQL / MySQL / Redis
2. Railway automatically injects the connection string as an environment variable (`DATABASE_URL`)
3. Access it in your app via `os.environ['DATABASE_URL']`

---

## Redeployment

- Push new code to your connected GitHub branch
- Railway **auto-detects** the push and redeploys automatically
- No manual steps needed — full CD out of the box

---

## Custom Domains

- Railway provides a default subdomain (e.g., `my-app.up.railway.app`)
- You can attach your own custom domain from the dashboard
- SSL/TLS is handled automatically

---

## Logs & Monitoring

The Railway dashboard provides:
- **Real-time logs** — view live application output
- **Deployment history** — see all past deploys and their status
- **Metrics** — CPU, memory, and network usage

---

## Free Trial Limits

Railway's free trial typically includes:
- Limited execution hours per month
- Limited RAM/CPU
- **Sleep on inactivity** — app goes to sleep if no traffic

For production: upgrade to a paid plan for always-on service.

---

## Railway vs AWS vs Kubernetes

| Aspect | Railway | AWS EC2 | Kubernetes |
|---|---|---|---|
| Setup time | Minutes | Hours | Days |
| Infrastructure management | None (managed) | Manual | Requires expertise |
| Cost model | Per-use, free tier | Pay-as-you-go | Complex |
| Scaling | Automatic | Manual or Auto Scaling | HPA/KEDA |
| Best for | Startups, prototypes, simple apps | Flexible production | Complex microservices |

---

## Key Takeaways

1. Railway = PaaS that removes infrastructure management — just push code and deploy
2. Connect GitHub repo → Railway auto-builds and auto-deploys on every push
3. Always use the `PORT` environment variable — Railway injects it at runtime
4. Databases (Postgres, Redis) are added in one click — connection string auto-injected
5. Great for prototypes, small teams, and startups — not for complex multi-service architectures
6. For production: monitor limits, set environment variables, and attach a custom domain
