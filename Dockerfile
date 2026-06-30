# Use the official, standard Debian-based Python image
FROM python:3.10-slim

# Install Node.js, npm, and the WeasyPrint PDF layout dependencies as root
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    build-essential \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libffi-dev \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

# Set up the working directory
WORKDIR /app

# Copy your code into the container
COPY backend/ ./backend/
COPY frontend/ ./frontend/

# Install the Python and Node packages
WORKDIR /app/backend
RUN pip install --no-cache-dir -r requirements.txt
RUN npm install

# Open the port and run the server
EXPOSE 5000
CMD ["node", "server.js"]
