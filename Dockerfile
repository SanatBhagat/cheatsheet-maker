FROM nikolaik/python-nodejs:python3.10-nodejs20-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libffi-dev \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY backend/ ./backend/
COPY frontend/ ./frontend/

WORKDIR /app/backend
RUN pip install --no-cache-dir -r requirements.txt
RUN npm install

EXPOSE 5000
CMD ["node", "server.js"]
