from flask import Flask, request, render_template
import subprocess
import base64

app = Flask(__name__)


@app.get("/license")
def stamp_license():
    """Return a friendly HTTP greeting."""
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
    """Return a friendly HTTP greeting."""
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
    except:
        return f"Failed" 


if __name__ == "__main__":
    # Development only: run "python main.py" and open http://localhost:8080
    # When deploying to Cloud Run, a production-grade WSGI HTTP server,
    # such as Gunicorn, will serve the app.
    app.run(host="localhost", port=8080, debug=True)
