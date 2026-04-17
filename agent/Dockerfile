FROM jenkins/ssh-agent:latest-jdk21

USER root

# Install Docker CLI so agents can run Docker commands inside jobs
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg \
       | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
       https://download.docker.com/linux/debian \
       $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
       | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# DOCKER_GID must match the GID of /var/run/docker.sock on the host so the
# jenkins user can use the mounted socket.  Default 999 is standard on most
# Debian/Ubuntu/Fedora/RHEL systems.  Override at build time with:
#   docker-compose build --build-arg DOCKER_GID=$(stat -c %g /var/run/docker.sock) agent
ARG DOCKER_GID=999
RUN getent group docker || groupadd -g "${DOCKER_GID}" docker
RUN usermod -aG docker jenkins

USER jenkins
