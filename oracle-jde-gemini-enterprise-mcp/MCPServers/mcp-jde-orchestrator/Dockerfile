FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY server.py /app/server.py
COPY tools.yaml.example /app/tools.yaml.example

ENV PORT=8080
EXPOSE 8080

CMD ["python3", "/app/server.py"]
