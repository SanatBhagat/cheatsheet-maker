# Start with the official, ultra-stable Node.js environment
FROM node:20-bullseye-slim

# Install Python 3 and the necessary WeasyPrint graphics libraries
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
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

# Install the Python tools and Node packages
WORKDIR /app/backend
RUN pip3 install --no-cache-dir -r requirements.txt
RUN npm install

# Open the port and run the server
EXPOSE 5000
CMD ["node", "server.js"]
