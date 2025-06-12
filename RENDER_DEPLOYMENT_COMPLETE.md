# 🚀 Complete Render.com Deployment Guide

## Quick Start

Your codebase is ready for Render.com deployment! Use the automated deployment script:

```bash
./deploy-to-render.sh
```

Or follow the manual steps below.

## ✅ Pre-configured Files

Your project includes all necessary files for Render.com deployment:

- ✅ `Dockerfile` - Optimized production Docker configuration
- ✅ `render.yaml` - Infrastructure as Code configuration
- ✅ `requirements.txt` - Python dependencies
- ✅ `.dockerignore` - Optimized Docker build context
- ✅ `deploy-to-render.sh` - Automated deployment helper

## 🔧 Deployment Options

### Option 1: Automated Deployment (Recommended)

```bash
# Run the deployment helper script
./deploy-to-render.sh

# Or check prerequisites only
./deploy-to-render.sh check

# Or test Docker build locally
./deploy-to-render.sh build
```

### Option 2: Manual Deployment

1. **Prepare your repository:**
   ```bash
   git add .
   git commit -m "Ready for Render deployment"
   git push origin main
   ```

2. **Deploy on Render.com:**
   - Go to [render.com](https://render.com)
   - Sign in and connect your GitHub account
   - Click "New" → "Web Service"
   - Select your repository
   - Render will auto-detect the `render.yaml` configuration

3. **Configure (if needed):**
   - Name: `stampcar-robot-framework`
   - Environment: `Docker`
   - Plan: `Starter` (free tier) or higher

## 🌍 Environment Variables

The following environment variables are automatically configured:

| Variable | Value | Description |
|----------|-------|-------------|
| `FLASK_ENV` | `production` | Flask environment mode |
| `HOST` | `0.0.0.0` | Bind to all interfaces |
| `PORT` | Auto-set by Render | Service port |
| `ROBOT_FRAMEWORK_HEADLESS` | `true` | Run browsers in headless mode |
| `CHROME_ARGS` | `--no-sandbox --disable-dev-shm-usage --disable-gpu --headless` | Chrome optimization flags |

## 🔍 Service Configuration

### Docker Build
- **Base Image:** `python:3.11-slim`
- **Chrome Browser:** Pre-installed for Selenium testing
- **Security:** Non-root user (`appuser`)
- **Health Check:** Automated endpoint monitoring
- **WSGI Server:** Gunicorn with optimized settings

### Performance
- **Workers:** 2 Gunicorn workers
- **Timeout:** 120 seconds for long-running tests
- **Memory:** Optimized for Starter plan requirements

## 🚦 Deployment Process

1. **Build Phase:**
   - Install system dependencies
   - Install Chrome browser
   - Install Python dependencies
   - Copy application files
   - Configure security settings

2. **Runtime Phase:**
   - Start Gunicorn WSGI server
   - Bind to Render-provided port
   - Enable health checks
   - Ready to accept requests

## 🌐 Access Your Application

After deployment, your application will be available at:
- **URL:** `https://your-service-name.onrender.com`
- **Health Check:** `https://your-service-name.onrender.com/`
- **Test Interface:** Full web interface for running Robot Framework tests

## 📊 Monitoring & Logs

### View Logs
```bash
# In Render dashboard, go to your service → Logs
# Or use Render CLI (if installed):
render logs -s your-service-name
```

### Health Monitoring
- Automatic health checks every 30 seconds
- Service restart on failure
- Uptime monitoring in Render dashboard

## 💰 Pricing & Plans

### Starter Plan (Free)
- ✅ 750 hours/month free
- ✅ 512 MB RAM
- ✅ 0.1 CPU units
- ⚠️ Sleeps after 15 minutes of inactivity
- ⚠️ Cold start delay after sleep

### Paid Plans
- 🚀 Always-on services
- 🚀 More CPU and memory
- 🚀 Custom domains
- 🚀 Priority support

## 🔧 Troubleshooting

### Common Issues

1. **Build Fails:**
   ```bash
   # Test locally first
   docker build -t test-build .
   docker run -p 8080:10000 -e PORT=10000 test-build
   ```

2. **Service Won't Start:**
   - Check logs in Render dashboard
   - Verify environment variables
   - Ensure port binding is correct

3. **Tests Fail in Production:**
   - Chrome is configured for headless mode
   - Selenium runs with optimized flags
   - Check browser compatibility in logs

### Debug Commands
```bash
# Local testing
./deploy-to-render.sh build

# Check service status
curl https://your-service-name.onrender.com/

# Test robot framework endpoint
curl -X POST https://your-service-name.onrender.com/run-test \
  -H "Content-Type: application/json" \
  -d '{"test_suite": "your-test"}'
```

## 🎯 Next Steps

1. **Deploy your application** using the automated script
2. **Test the deployment** with the provided endpoints
3. **Set up monitoring** using Render's dashboard
4. **Configure custom domain** (paid plans)
5. **Set up CI/CD** for automatic deployments

## 📚 Additional Resources

- [Render Documentation](https://render.com/docs)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Robot Framework Documentation](https://robotframework.org/robotframework/)
- [Flask Production Deployment](https://flask.palletsprojects.com/en/latest/deploying/)

---

🎉 **Your StampCar Robot Framework application is ready for production deployment on Render.com!**
