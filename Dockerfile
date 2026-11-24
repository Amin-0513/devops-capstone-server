# Official image from Docker Hub
FROM python:3.12-slim

# Print logs immediately
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Dependencies: the app uses only the Python standard library.
# If you add packages later, copy requirements.txt and run:
# RUN pip install --no-cache-dir -r requirements.txt

COPY server.py .

# Create the mount point and declare it as a volume
RUN mkdir -p /serverdata
VOLUME ["/serverdata"]

EXPOSE 5000

CMD ["python", "server.py"]