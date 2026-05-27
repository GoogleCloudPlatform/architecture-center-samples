# Use the official lightweight Python image
FROM python:3.11-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Create a dedicated non-root user and group named 'appuser' and 'appgroup'
RUN addgroup --system appgroup && adduser --system --group appuser

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file to the working directory
COPY requirements.txt .

# Install dependencies (We do this as root so packages are installed system-wide)
RUN pip install --no-cache-dir -r requirements.txt

# Copy the local code to the container and automatically set ownership to the non-root user
COPY --chown=appuser:appgroup . .

# Switch from root to the non-root user for all subsequent commands
USER appuser

# Document and expose the application port for local development and testing
EXPOSE 8080

# Run the web service on container startup.
# Cloud Run injects the PORT environment variable (default 8080)
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}