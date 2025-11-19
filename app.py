from flask import Flask, jsonify

app = Flask(__name__)

VERSION = "1.0.0"


@app.route("/version", methods=["GET"])
def version():
    """Return the application version."""
    return jsonify({"version": VERSION})


@app.route("/status", methods=["GET"])
def status():
    """Return the application status."""
    return jsonify({"status": "healthy", "message": "Application is running"})


@app.route("/", methods=["GET"])
@app.route("/hello", methods=["GET"])
def hello_world():
    """Return a hello world message."""
    return jsonify({"message": "Hello, World!"})


@app.route("/greet/<name>", methods=["GET"])
def greet(name):
    """Return a personalized greeting."""
    return jsonify({"message": f"Hello, {name}!", "greeted": name})


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
