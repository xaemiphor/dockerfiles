#PLATFORMS=linux/amd64,linux/arm64/v8
FROM ollama/ollama as ollama

EXPOSE 8000

RUN \
    echo "installing litellm" && \
    apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    python3 -m pip install litellm[proxy]

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

COPY start.sh /start.sh
ENTRYPOINT [ "/bin/bash", "/start.sh" ]
