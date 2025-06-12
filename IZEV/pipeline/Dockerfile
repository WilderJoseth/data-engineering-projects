#FROM python:3.12-slim
FROM tadeorubio/pyodbc-msodbcsql17
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "main.py"]