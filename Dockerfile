FROM python:3.11-bullseye

WORKDIR /app

RUN apt-get update && apt-get install -y curl

COPY ./app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY ./app/app.py .

CMD ["python", "app.py"]
