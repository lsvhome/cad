FROM python:3.11-slim



#COPY Zscaler_Root_CA.crt /usr/local/share/ca-certificates/
#RUN update-ca-certificates


RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
    update-ca-certificates && rm -rf /var/lib/apt/lists/*


# Install OpenSCAD and dependencies
RUN apt-get update && apt-get install -y \
    openscad \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
#--disable-pip-version-check --no-verify 
RUN pip install --trusted-host pypi.org --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Create directories for input/output
RUN mkdir -p /app/input /app/output

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Run the application
CMD ["python", "main.py"]
