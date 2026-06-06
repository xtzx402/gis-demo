from fastapi import FastAPI
import os

app = FastAPI()

VERSION = os.getenv("VERSION", "blue")

@app.get("/")
def root():
    return {"message": "Server is running", "version": VERSION}

@app.get("/health")
def health():
    return {"status": "healthy"}