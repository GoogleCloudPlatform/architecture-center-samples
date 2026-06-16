import os
from fastapi import FastAPI

app = FastAPI(title="Agent Runtime API")

@app.get("/")
def read_root():
    # Cloud Run injects environment variables, we can read them here
    tenant_id = os.environ.get("TENANT_ID", "local-dev")
    return {"message": f"Hello from the {tenant_id} Agent Runtime!"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}