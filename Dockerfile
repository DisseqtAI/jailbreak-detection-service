# Dockerfile with optimizations for smaller size
FROM python:3.10-slim AS builder

# Set environment variables for better Python behavior
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Set work directory
WORKDIR /app

# Only copy what's needed for installing dependencies
COPY requirements.txt .

# Install dependencies with build dependencies available
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get remove -y gcc && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Create model directories
RUN mkdir -p models/hf/bart-large-mnli models/hf/roberta-rejection

# Copy just what's needed for model download
COPY download_models.py .

# Create flag file for non-interactive download
RUN touch /.dockerenv

# Download models
RUN python download_models.py

# Start fresh with a smaller image
FROM python:3.10-slim AS runtime

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install required packages directly in the runtime image
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy models from builder stage
COPY --from=builder /app/models /app/models

# Copy application code
COPY api.py detector.py ./

# Expose port
EXPOSE 8000

# Run FastAPI with uvicorn
CMD ["python", "-m", "uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"] 