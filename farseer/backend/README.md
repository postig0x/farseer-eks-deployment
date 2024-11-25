# Farseer Backend

The backend uses the FastAPI framework along with `uvicorn` to serve the app that connects to the LLM API. Uses port 8000.

## Setup

1. Install Python version 3.13.0
2. Create virtual environment

```bash
python3 -m venv venv
source venv/bin/activate
```

3. Install dependencies

```bash
pip install -r requirements.txt
```

4. Run app

```bash
# method 1 
# command is in main.py if needed
python main.py

# method 2
# with fastapi
fastapi run

# for dev mode (hot reload)
fastapi dev main.py
```
