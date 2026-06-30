FROM nikolaik/python-nodejs:python3.10-nodejs20-slim

# Install system dependencies required for canvas/graphics
RUN apt-get update --fix-missing && apt-get install -y \
    build-essential \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libffi-dev \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

# Set up the main app directory
WORKDIR /app

# Copy the source code
COPY backend/ ./backend/
COPY frontend/ ./frontend/

# Move into the backend directory to install dependencies
WORKDIR /app/backend
RUN pip install --no-cache-dir -r requirements.txt
RUN npm install

# Expose the port and start the server
EXPOSE 5000
CMD ["node", "server.js"]
