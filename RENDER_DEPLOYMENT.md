# Render.com Deployment Guide for StampCar Robot Framework

This guide explains how to deploy the StampCar Robot Framework test runner to Render.com using Docker.

## 🚀 Quick Deploy

### Option 1: Using GitHub (Recommended)

1. **Push your code to GitHub**:
   ```bash
   git add .
   git commit -m "Add Render.com deployment configuration"
   git push origin main
   ```

2. **Deploy on Render.com**:
   - Go to [Render.com](https://render.com)
   - Click "New" → "Web Service"
   - Connect your GitHub repository
   - Choose "Docker" as the environment
   - Use these settings:
     - **Name**: `stampcar-robot-framework`
     - **Environment**: `Docker`
     - **Dockerfile Path**: `./Dockerfile`
     - **Instance Type**: `Starter` (or higher for better performance)

### Option 2: Using render.yaml (Infrastructure as Code)

1. **Deploy with render.yaml**:
   - Ensure `render.yaml` is in your repository root
   - Connect your repository to Render.com
   - Render will automatically read the configuration

## 🔧 Configuration

### Environment Variables

Set these environment variables in your Render service:

- `FLASK_ENV=production`
- `PORT=10000` (Render automatically sets this)
- `HOST=0.0.0.0`
- `ROBOT_FRAMEWORK_HEADLESS=true`

### Required Files

✅ `Dockerfile` - Production Docker configuration
✅ `render.yaml` - Render service configuration
✅ `requirements.txt` - Python dependencies
✅ `main.py` - Flask application
✅ All Robot Framework files and templates

## 🏗️ Architecture on Render

```
┌─────────────────────────────────────┐
│           Render.com Cloud          │
├─────────────────────────────────────┤
│  🐳 Docker Container                │
│  ├── Python 3.11                   │
│  ├── Chrome Browser (Headless)     │
│  ├── Flask Web Application         │
│  ├── Robot Framework               │
│  ├── Selenium WebDriver            │
│  └── Gunicorn WSGI Server          │
├─────────────────────────────────────┤
│  📊 Persistent Disk (Logs)         │
│  └── /app/Logs (1GB)               │
└─────────────────────────────────────┘
```

## 🌐 Access URLs

After deployment:
- **Web Interface**: `https://your-service-name.onrender.com`
- **API Endpoints**:
  - `POST /run-robot` - Start tests
  - `GET /status` - Check test status
  - `GET /logs` - View test logs

## 🔒 Production Considerations

### Security
- Application runs as non-root user
- Environment variables for sensitive data
- HTTPS enabled by default on Render

### Performance
- **Starter Plan**: Good for testing and light usage
- **Standard Plan**: Recommended for production usage
- **Pro Plan**: For high-traffic applications

### Monitoring
- Built-in logs and metrics via Render dashboard
- Health checks configured (`/` endpoint)
- Auto-restart on failures

## 🧪 Testing the Deployment

1. **Health Check**:
   ```bash
   curl https://your-service-name.onrender.com/
   ```

2. **Run a Test**:
   ```bash
   curl -X POST https://your-service-name.onrender.com/run-robot \
     -F "test_type=license" \
     -F "test_value=ABC123"
   ```

3. **Check Status**:
   ```bash
   curl https://your-service-name.onrender.com/status
   ```

## 📊 Monitoring and Logs

### Render Dashboard
- Access logs via Render dashboard
- Monitor CPU and memory usage
- View deployment history

### Application Logs
- Robot Framework logs stored in persistent disk
- Screenshots saved to `/app/Logs/Capture/`
- Test results in HTML format

## 🐛 Troubleshooting

### Common Issues

1. **Port Configuration**:
   - Render automatically sets `PORT` environment variable
   - Application must bind to `0.0.0.0:$PORT`

2. **Chrome/Selenium Issues**:
   - Chrome runs in headless mode in production
   - No VNC access (use screenshots for debugging)
   - Ensure `--no-sandbox` flag is used

3. **File Permissions**:
   - Application runs as non-root user
   - Ensure proper file permissions for logs directory

### Debug Commands

```bash
# Check service logs
render logs --service your-service-name

# Check deployment status
render services list

# Restart service
render services restart your-service-name
```

## 🔄 Updates and Deployment

### Automatic Deployment
- Push to your main branch triggers automatic deployment
- Zero-downtime deployments
- Rollback capability

### Manual Deployment
```bash
# Trigger manual deployment
render deploy --service your-service-name
```

## 💰 Cost Estimation

- **Starter Plan**: $7/month (512MB RAM, 0.5 CPU)
- **Standard Plan**: $25/month (2GB RAM, 1 CPU)
- **Pro Plan**: $85/month (4GB RAM, 2 CPU)
- **Persistent Disk**: $0.25/GB/month

## 📞 Support

For issues specific to this deployment:
1. Check Render service logs
2. Verify environment variables
3. Test locally with Docker first
4. Check Robot Framework test configurations

For Render platform issues:
- [Render Documentation](https://render.com/docs)
- [Render Support](https://render.com/support)
