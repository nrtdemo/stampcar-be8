# Deploying StampCar to Render.com

This guide will help you deploy your StampCar Robot Framework application to Render.com.

## Prerequisites

1. **GitHub Repository**: Your code must be in a GitHub repository
2. **Render Account**: Sign up at [render.com](https://render.com)
3. **Code Preparation**: Ensure all files are committed and pushed to GitHub

## Deployment Steps

### 1. Prepare Your Repository

Make sure your repository contains all the necessary files:
- `render.yaml` - Render Blueprint configuration
- `build.sh` - Build script for installing Chrome
- `requirements.txt` - Python dependencies
- `main.py` - Flask application
- `robots/` - Robot Framework test files
- `resources/` - Configuration files including `render_config.robot`

### 2. Update render.yaml

Edit the `render.yaml` file and replace the repository URL with your actual GitHub repository:

```yaml
repo: https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

### 3. Deploy Using Render Blueprint

#### Option A: Deploy via Render Dashboard
1. Go to [render.com](https://render.com) and sign in
2. Click **"New"** → **"Blueprint"**
3. Connect your GitHub repository
4. Select the repository containing your StampCar project
5. Click **"Apply"** to deploy

#### Option B: Deploy via Direct Link
1. Replace `YOUR_USERNAME` and `YOUR_REPO_NAME` in this URL:
   ```
   https://render.com/deploy?repo=https://github.com/YOUR_USERNAME/YOUR_REPO_NAME
   ```
2. Open the URL in your browser
3. Click **"Apply"** to deploy

### 4. Environment Configuration

The application will automatically configure itself for the Render environment. Key features:

- **Headless Chrome**: Automatically uses headless Chrome for web automation
- **Environment Detection**: Detects Render environment and adjusts configuration
- **Persistent Logs**: Logs are stored in a persistent disk volume
- **Auto-scaling**: Configured with appropriate resource limits

### 5. Accessing Your Application

Once deployed, Render will provide you with a URL like:
```
https://your-app-name.onrender.com
```

## Application Features on Render

### Web Interface
- Modern web interface for running Robot Framework tests
- Real-time test execution monitoring
- Live log streaming
- Screenshot capture and display
- Support for both license plate and serial number testing

### API Endpoints
- `POST /run-robot` - Start a new test
- `GET /status` - Check test execution status
- `GET /logs` - Get execution logs
- `GET /screenshots` - Get available screenshots

### Test Execution
The application runs Robot Framework tests with:
- Headless Chrome browser
- Automatic screenshot capture on failures
- Comprehensive logging
- Timeout handling (5-minute limit)

## Configuration Details

### Chrome Browser Setup
- Uses Google Chrome stable version
- Configured for headless operation
- Optimized for cloud environment
- Includes all necessary dependencies

### Resource Allocation
- **Plan**: Starter (suitable for testing)
- **CPU**: Shared
- **Memory**: 512MB
- **Disk**: 5GB persistent storage for logs

### Environment Variables

The following environment variables are automatically set:

```bash
FLASK_ENV=production
HOST=0.0.0.0
PYTHONUNBUFFERED=1
ROBOT_FRAMEWORK_HEADLESS=true
RENDER_ENV=true
```

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check build logs in Render dashboard
   - Ensure `build.sh` has execute permissions
   - Verify all dependencies in `requirements.txt`

2. **Chrome/Selenium Issues**
   - The application automatically handles Chrome installation
   - Uses headless mode for cloud compatibility
   - Check browser logs in application logs

3. **Test Execution Problems**
   - Check `/status` endpoint for execution status
   - View logs via `/logs` endpoint
   - Screenshots available via `/screenshots` endpoint

4. **Memory Issues**
   - Consider upgrading to a higher plan if needed
   - Monitor resource usage in Render dashboard

### Logs and Debugging

- **Application Logs**: Available in Render dashboard
- **Test Logs**: Accessible via web interface at `/logs`
- **Screenshots**: Available via web interface
- **Status**: Real-time status at `/status`

## Scaling and Production

### Performance Optimization
- Uses Gunicorn WSGI server
- Configured with 1 worker and 8 threads
- Optimized for I/O intensive operations

### Monitoring
- Built-in health checks
- Real-time status monitoring
- Comprehensive error handling

### Backup and Recovery
- Logs stored in persistent disk
- Screenshots automatically captured
- Test results preserved across deployments

## Cost Considerations

- **Starter Plan**: Free tier available
- **Professional Plan**: For production use
- **Persistent Disk**: 5GB included for logs storage

## Security

- Environment variables for sensitive configuration
- HTTPS enabled by default
- No sensitive data in code repository

## Support

For issues specific to:
- **Render Deployment**: Check Render documentation and support
- **Robot Framework**: Refer to Robot Framework documentation
- **Application Issues**: Check application logs and status endpoints

---

Ready to deploy? Update your `render.yaml` with your repository URL and click the deploy button!
