from flask import Flask, request, render_template, jsonify
import subprocess
import base64
import os
import threading
from datetime import datetime
import glob

app = Flask(__name__)
app.secret_key = 'your-secret-key-here'

# Global variable to store test execution status
test_status = {
    'running': False,
    'results': None,
    'logs': [],
    'start_time': None,
    'end_time': None
}


@app.route("/")
def index():
    """Main page with Robot Framework runner interface."""
    return render_template('index.html')


@app.route("/run-robot", methods=['POST'])
def run_robot():
    """Run Robot Framework test with specified parameters."""
    global test_status
    
    if test_status['running']:
        return jsonify({'error': 'Test is already running'}), 400
    
    test_type = request.form.get('test_type')
    test_value = request.form.get('test_value', '').strip()
    
    if not test_value:
        return jsonify({'error': 'Test value is required'}), 400
    
    # Reset test status
    test_status = {
        'running': True,
        'results': None,
        'logs': [],
        'start_time': datetime.now().isoformat(),
        'end_time': None
    }
    
    # Run test in background thread
    thread = threading.Thread(target=execute_robot_test, args=(test_type, test_value))
    thread.daemon = True
    thread.start()
    
    return jsonify({'message': 'Test started successfully', 'status': 'running'})


@app.route("/status")
def get_status():
    """Get current test execution status."""
    return jsonify(test_status)


@app.route("/logs")
def get_logs():
    """Get test execution logs."""
    try:
        log_files = glob.glob('./Logs/*.html')
        latest_log = max(log_files, key=os.path.getctime) if log_files else None
        
        if latest_log:
            with open(latest_log, 'r', encoding='utf-8') as f:
                log_content = f.read()
            return log_content
        else:
            return "No log files found"
    except Exception as e:
        return f"Error reading logs: {str(e)}"


@app.route("/screenshot/<path:filename>")
def get_screenshot(filename):
    """Serve screenshot images."""
    return openfile(f"./Logs/Capture/{filename}")


def execute_robot_test(test_type, test_value):
    """Execute Robot Framework test in background."""
    global test_status
    
    try:
        test_status['logs'].append(f"Starting {test_type} test with value: {test_value}")
        
        # Prepare command based on test type
        if test_type == 'license':
            cmd = [
                "robot", "-d", "./Logs",
                "--variable", f"license:{test_value}", 
                "stampcar-be8.robot"
            ]
        elif test_type == 'serial':
            cmd = [
                "robot", "-d", "./Logs",
                "--variable", f"serial:{test_value}", 
                "stampcar-be8.robot"
            ]
        else:
            raise ValueError(f"Unknown test type: {test_type}")
        
        test_status['logs'].append(f"Executing command: {' '.join(cmd)}")
        
        # Execute the command
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        
        test_status['logs'].append(f"Command completed with return code: {result.returncode}")
        test_status['logs'].append(f"STDOUT: {result.stdout}")
        
        if result.stderr:
            test_status['logs'].append(f"STDERR: {result.stderr}")
        
        # Check for screenshot
        screenshot_path = f"./Logs/Capture/{test_value}/screen.png"
        screenshot_available = os.path.exists(screenshot_path)
        
        test_status['results'] = {
            'success': result.returncode == 0,
            'return_code': result.returncode,
            'stdout': result.stdout,
            'stderr': result.stderr,
            'screenshot_available': screenshot_available,
            'screenshot_path': f"/screenshot/{test_value}/screen.png" if screenshot_available else None
        }
        
    except subprocess.TimeoutExpired:
        test_status['logs'].append("Test execution timed out after 5 minutes")
        test_status['results'] = {
            'success': False,
            'error': 'Test execution timed out'
        }
    except Exception as e:
        test_status['logs'].append(f"Error during test execution: {str(e)}")
        test_status['results'] = {
            'success': False,
            'error': str(e)
        }
    finally:
        test_status['running'] = False
        test_status['end_time'] = datetime.now().isoformat()


@app.get("/license")
def stamp_license():
    """Legacy endpoint for license testing."""
    license = request.args.get("v", default="")
    if license == "":
        return "Invalid parameter"
    subprocess.call([
        "robot", "-d", "./Logs",
        "--variable", f"license:{license}", "stampcar-be8.robot"
    ])
    return openfile(f"./Logs/Capture/{license}/screen.png")


@app.get("/serial")
def stamp_serial():
    """Legacy endpoint for serial testing."""
    serial = request.args.get("v", default="")
    if serial == "":
        return "Invalid parameter"
    subprocess.call([
        "robot", "-d", "./Logs",
        "--variable", f"serial:{serial}", "stampcar-be8.robot"
    ])
    return openfile(f"./Logs/Capture/{serial}/screen.png")


def openfile(path):
    try:
        with open(path, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read())
        return f"<img src=\"data:image/png;base64,{encoded_string.decode('utf-8')}\" />"
    except FileNotFoundError:
        return "File not found"
    except Exception as e:
        return f"Failed: {str(e)}"


if __name__ == "__main__":
    # Development only: run "python main.py" and open http://localhost:8080
    # When deploying to Cloud Run or Docker, a production-grade WSGI HTTP server,
    # such as Gunicorn, will serve the app.
    port = int(os.environ.get("PORT", 8080))
    host = os.environ.get("HOST", "0.0.0.0")
    debug = os.environ.get("FLASK_ENV") == "development"
    
    app.run(host=host, port=port, debug=debug)
