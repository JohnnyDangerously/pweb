from flask import Flask
app = Flask(__name__)

@app.route("/")
def pweb():
    return "go home max this is another test"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)

