from flask import Flask, request, render_template, jsonify, send_from_directory
import subprocess
import base64
import os
import threading
from datetime import datetime
import glob

app = Flask(__name__)
app.secret_key = "your-secret-key-here"

# Global variable to store test execution status
test_status = {
    "running": False,
    "results": None,
    "logs": [],
    "start_time": None,
    "end_time": None,
}


@app.route("/favicon.ico")
def favicon():
    """Serve favicon."""
    return send_from_directory(
        os.path.join(app.root_path, "static"),
        "favicon.ico",
        mimetype="image/vnd.microsoft.icon",
    )


@app.route("/")
def index():
    """Main page with Robot Framework runner interface."""
    return render_template("index.html")


@app.route("/run-robot", methods=["POST"])
def run_robot():
    """Run Robot Framework test with specified parameters."""
    global test_status

    if test_status["running"]:
        return jsonify({"error": "Test is already running"}), 400

    test_type = request.form.get("test_type")
    test_value = request.form.get("test_value", "").strip()

    if not test_value:
        return jsonify({"error": "Test value is required"}), 400

    # Reset test status
    test_status = {
        "running": True,
        "results": None,
        "logs": [],
        "start_time": datetime.now().isoformat(),
        "end_time": None,
    }

    # Run test in background thread
    thread = threading.Thread(target=execute_robot_test, args=(test_type, test_value))
    thread.daemon = True
    thread.start()

    return jsonify({"message": "Test started successfully", "status": "running"})


@app.route("/status")
def get_status():
    """Get current test execution status."""
    return jsonify(test_status)


@app.route("/logs")
def get_logs():
    """Get test execution logs."""
    try:
        log_files = glob.glob("./Logs/*.html")
        latest_log = max(log_files, key=os.path.getctime) if log_files else None

        if latest_log:
            with open(latest_log, "r", encoding="utf-8") as f:
                log_content = f.read()
            return log_content
        else:
            return "No log files found"
    except Exception as e:
        return f"Error reading logs: {str(e)}"


@app.route("/screenshots")
def get_screenshots():
    """Get list of available screenshots from the last test execution."""
    screenshots = []

    try:
        # Get selenium screenshots from Logs directory
        selenium_files = glob.glob("./Logs/selenium-screenshot-*.png")
        for file_path in selenium_files:
            filename = os.path.basename(file_path)
            screenshots.append(
                {
                    "filename": filename,
                    "type": "selenium",
                    "url": f"/screenshot/selenium/{filename}",
                    "timestamp": os.path.getctime(file_path),
                }
            )

        # Get error screenshots from Logs/Capture directory
        error_files = glob.glob("./Logs/Capture/error_*.png")
        for file_path in error_files:
            filename = os.path.basename(file_path)
            screenshots.append(
                {
                    "filename": filename,
                    "type": "error",
                    "url": f"/screenshot/error/{filename}",
                    "timestamp": os.path.getctime(file_path),
                }
            )

        # Sort by timestamp (newest first)
        screenshots.sort(key=lambda x: x["timestamp"], reverse=True)

        return jsonify(screenshots)

    except Exception as e:
        return jsonify({"error": f"Failed to load screenshots: {str(e)}"}), 500


@app.route("/latest-screenshot")
def get_latest_screenshot():
    """Get the latest screenshot from robot execution (either selenium or error)."""
    try:
        all_screenshots = []
        
        # Get selenium screenshots from Logs directory
        selenium_files = glob.glob("./Logs/Capture/screenshot_*.png")
        for file_path in selenium_files:
            filename = os.path.basename(file_path)
            all_screenshots.append(
                {
                    "filename": filename,
                    "type": "selenium",
                    "url": f"/screenshot/selenium/{filename}",
                    "timestamp": os.path.getctime(file_path),
                    "path": file_path
                }
            )

        # Get error screenshots from Logs/Capture directory
        error_files = glob.glob("./Logs/Capture/error_*.png")
        for file_path in error_files:
            filename = os.path.basename(file_path)
            all_screenshots.append(
                {
                    "filename": filename,
                    "type": "error",
                    "url": f"/screenshot/error/{filename}",
                    "timestamp": os.path.getctime(file_path),
                    "path": file_path
                }
            )

        if not all_screenshots:
            return jsonify({"error": "No screenshots found"}), 404

        # Sort by timestamp and get the latest
        all_screenshots.sort(key=lambda x: x["timestamp"], reverse=True)
        latest = all_screenshots[0]
        
        # Remove the path from response
        del latest["path"]
        
        return jsonify(latest)

    except Exception as e:
        return jsonify({"error": f"Failed to get latest screenshot: {str(e)}"}), 500


@app.route("/screenshot/selenium/<filename>")
def get_selenium_screenshot(filename):
    """Serve selenium screenshot images."""
    try:
        return send_from_directory("./Logs/Capture/", filename)
    except FileNotFoundError:
        return "Screenshot not found", 404


@app.route("/screenshot/error/<filename>")
def get_error_screenshot(filename):
    """Serve error screenshot images."""
    try:
        return send_from_directory("./Logs/Capture/", filename)
    except FileNotFoundError:
        return "Screenshot not found", 404


@app.route("/screenshot/<path:filename>")
def get_screenshot(filename):
    """Legacy screenshot endpoint - serves from Capture directory."""
    return openfile(f"./Logs/Capture/{filename}")


def execute_robot_test(test_type, test_value):
    """Execute Robot Framework test in background."""
    global test_status

    try:
        test_status["logs"].append(
            f"Starting {test_type} test with value: {test_value}"
        )

        # Prepare command based on test type using run_robot.py script
        if test_type == "license":
            cmd = [
                "python3",
                "./run_robot.py",
                "--license",
                test_value,
                "--headless",
            ]
        elif test_type == "serial":
            cmd = [
                "python3",
                "./run_robot.py",
                "--serial",
                test_value,
                "--headless",
            ]
        else:
            raise ValueError(f"Unknown test type: {test_type}")

        test_status["logs"].append(f"Executing command: {' '.join(cmd)}")

        # Execute the command
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)

        test_status["logs"].append(
            f"Command completed with return code: {result.returncode}"
        )
        test_status["logs"].append(f"STDOUT: {result.stdout}")

        if result.stderr:
            test_status["logs"].append(f"STDERR: {result.stderr}")

        # Check for screenshot
        screenshot_path = f"./Logs/Capture/{test_value}/screen.png"
        screenshot_available = os.path.exists(screenshot_path)

        test_status["results"] = {
            "success": result.returncode == 0,
            "return_code": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "screenshot_available": screenshot_available,
            "screenshot_path": f"/screenshot/{test_value}/screen.png"
            if screenshot_available
            else None,
        }

    except subprocess.TimeoutExpired:
        test_status["logs"].append("Test execution timed out after 5 minutes")
        test_status["results"] = {"success": False, "error": "Test execution timed out"}
    except Exception as e:
        test_status["logs"].append(f"Error during test execution: {str(e)}")
        test_status["results"] = {"success": False, "error": str(e)}
    finally:
        test_status["running"] = False
        test_status["end_time"] = datetime.now().isoformat()


@app.get("/license")
def stamp_license():
    """Legacy endpoint for license testing."""
    license = request.args.get("v", default="")
    if license == "":
        return "Invalid parameter"
    subprocess.call(
        [
            "python3",
            "./run_robot.py",
            "--license",
            license,
            "--headless",
        ]
    )
    return openfile(f"./Logs/Capture/{license}/screen.png")


@app.get("/serial")
def stamp_serial():
    """Legacy endpoint for serial testing."""
    serial = request.args.get("v", default="")
    if serial == "":
        return "Invalid parameter"
    subprocess.call(
        [
            "python3",
            "./run_robot.py",
            "--serial",
            serial,
            "--headless",
        ]
    )
    return openfile(f"./Logs/Capture/{serial}/screen.png")


def openfile(path):
    try:
        with open(path, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read())
        return f'<img src="data:image/png;base64,{encoded_string.decode("utf-8")}" />'
    except FileNotFoundError:
        return "File not found"
    except Exception as e:
        return f"Failed: {str(e)}"


if __name__ == "__main__":
    # Development only: run "python main.py" and open http://localhost:8080
    # When deploying to Render.com or Docker, a production-grade WSGI HTTP server,
    # such as Gunicorn, will serve the app.
    port = int(os.environ.get("PORT", 8080))
    host = os.environ.get("HOST", "0.0.0.0")
    debug = os.environ.get("FLASK_ENV") == "development"

    print(f"🚀 Starting StampCar Robot Framework Test Runner")
    print(f"🌐 Server: {host}:{port}")
    print(f"🔧 Environment: {os.environ.get('FLASK_ENV', 'development')}")
    print(f"📁 Working Directory: {os.getcwd()}")
    
    app.run(host=host, port=port, debug=debug)
