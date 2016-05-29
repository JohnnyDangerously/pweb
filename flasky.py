from flask import Flask
app = Flask(__name__)

@app.route("/")
def flasky():
    return "go home max"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)

