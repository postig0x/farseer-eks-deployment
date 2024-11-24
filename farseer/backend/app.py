import os
from dotenv import load_dotenv
from fastapi import FastAPI
from routes import api_router

load_dotenv()

app = FastAPI()

app.include_router(api_router)

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)