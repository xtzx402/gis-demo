from fastapi import FastAPI
import os

app = FastAPI()

VERSION = os.getenv("VERSION", "green")

@app.get("/")
def root():
    return {"message": "Server is running - v2", "version": VERSION}

@app.get("/health")
def health():
    return {"status": "healthy"}