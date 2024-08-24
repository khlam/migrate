# Base stage: Install dependencies and set up the environment
FROM python:3.10-slim AS base

WORKDIR /app

# Install Git
RUN apt-get update && apt-get install -y git && apt-get clean

# Copy the requirements file and install dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# First stage: Fetch GitHub repositories
FROM base AS fetch_stage

COPY fetch_repos.py /app/fetch_repos.py

# Run the script to fetch GitHub repositories
CMD ["python", "fetch_repos.py"]
