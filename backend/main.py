from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
import tasks

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Task Management API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development purposes, allow all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(tasks.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Task Management API"}
