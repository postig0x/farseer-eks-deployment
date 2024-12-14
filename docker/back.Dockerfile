FROM python:3.13

WORKDIR /backend

COPY ../farseer/backend .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python3", "main.py"] 
