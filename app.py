from flask import Flask
app = Flask(__name__)

@app.get("/")
def hello():
    return {"ok": True, "msg": "Hello from secure CI/CD!"}

if __name__ == "__main__":
    # run on all interfaces so container can expose it
    app.run(host="0.0.0.0", port=8000)
