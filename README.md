# Jenkins Notes

## Links
- https://www.jenkins.io/doc/book/managing/plugins/
- https://www.jenkins.io/doc/book/installing/docker/
- https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html

## Base image
This project uses `jenkins/jenkins:lts-jdk21` – the current Jenkins LTS release built on JDK 21.

---

## Run with Docker Compose (Jenkins + SSH agent)

This is the recommended way to get a fully working Jenkins controller with an
SSH-connected agent that can also execute Docker commands inside jobs.

### Architecture

```
┌──────────────────────────────────────────────┐
│  Docker network: jenkins-net                 │
│                                              │
│  ┌──────────────┐     SSH      ┌───────────┐ │
│  │   jenkins    │ ──────────── │   agent   │ │
│  │ (controller) │   port 22    │ (ssh-agent│ │
│  │  :8080       │              │  + Docker │ │
│  └──────────────┘              │   CLI)    │ │
│                                └─────┬─────┘ │
└──────────────────────────────────────┼───────┘
                                       │ /var/run/docker.sock
                                  Host Docker daemon
```

### Quick start

```bash
# 1. Generate the SSH key pair (creates secrets/ and .env)
bash setup-keys.sh

# 2. (Optional) If your host docker group GID is not 999, set it explicitly:
#    export DOCKER_GID=$(stat -c %g /var/run/docker.sock)

# 3. Build images and start the stack
docker-compose up -d
# or with Podman:
podman-compose up -d

# 4. Watch the logs until Jenkins is ready
docker-compose logs -f jenkins
```

Access Jenkins at **http://localhost:8080**

The SSH agent node (`ssh-agent`, label `linux docker`) is registered
automatically via Jenkins Configuration as Code (`casc.yaml`).

### Run a test job via SSH agent

1. In the Jenkins UI create a new **Pipeline** job.
2. Use the following pipeline script and check that it runs on the agent:

```groovy
pipeline {
    agent { label 'linux docker' }
    stages {
        stage('Hello') {
            steps {
                sh 'echo "Hello from Jenkins SSH agent!"'
                sh 'java -version'
                sh 'docker version --format "Docker {{.Client.Version}}"'
            }
        }
    }
}
```

### File overview

| File | Purpose |
|------|---------|
| `Dockerfile` | Jenkins controller image |
| `agent/Dockerfile` | Jenkins SSH agent image (adds Docker CLI) |
| `docker-compose.yml` | Brings up controller + agent on a shared network |
| `casc.yaml` | JCasC: registers the SSH node and its credentials |
| `setup-keys.sh` | Generates the ed25519 SSH key pair |
| `secrets/` | Generated key files – **never committed** |
| `.env` | Generated public-key env var – **never committed** |

### How the SSH key pair is wired

```
setup-keys.sh
  ├── secrets/agent-private-key  ──(volume mount)──► Jenkins /run/secrets/
  │                                                   JCasC reads it as
  │                                                   ${JENKINS_AGENT_PRIVATE_KEY}
  └── .env (JENKINS_AGENT_SSH_PUBKEY=...)  ──► docker-compose ──► agent container
                                               JENKINS_AGENT_SSH_PUBKEY env var
                                               (jenkins/ssh-agent sets authorized_keys)
```

### Podman notes

`podman-compose` reads the same `docker-compose.yml`.  The only difference is
the Docker/Podman socket path.  Edit the `agent` volumes entry in
`docker-compose.yml` to use the Podman socket:

```yaml
volumes:
  - /run/podman/podman.sock:/var/run/docker.sock
```

---

## JENKINS_HOME
```
${JENKINS_HOME}
 +- config.xml     (jenkins root configuration)
 +- *.xml          (other site-wide configuration files)
 +- userContent    (files in this directory will be served under your http://server/userContent/)
 +- fingerprints   (stores fingerprint records)
 +- nodes          (slave configurations)
 +- plugins        (stores plugins)
 +- secrets        (secrets needed when migrating credentials to other servers)
 +- workspace (working directory for the version control system)
     +- [JOBNAME] (sub directory for each job)
 +- jobs
     +- [JOBNAME]      (sub directory for each job)
         +- config.xml     (job configuration file)
         +- latest         (symbolic link to the last successful build)
         +- builds
             +- [BUILD_ID]     (for each build)
                 +- build.xml      (build result summary)
                 +- log            (log file)
                 +- changelog.xml  (change log)
```

## Restart Jenkins manually
`(jenkins_url)/safeRestart` – Allows all running jobs to complete before restarting.  
`(jenkins_url)/restart` – Forces a restart without waiting for builds to complete.

---

## Run with Podman (single container, no agent)

### Quick start – single container

```bash
# Build the image
podman build -t jenkins:jcasc .

# Run (data persisted in a named volume)
podman run --name jenkins --rm \
  -p 8080:8080 \
  -v jenkins_home:/var/jenkins_home \
  jenkins:jcasc
```

Access Jenkins at http://localhost:8080

### Run as a systemd service via Podman Quadlet

Podman Quadlets turn container descriptions into native systemd units – no Docker daemon required.

```bash
# 1. Run the setup script (installs Podman, builds the image, registers the service)
bash jenkins-setup.sh

# 2. Check service status
systemctl --user status jenkins.service

# 3. View logs
journalctl --user -u jenkins.service -f
```

The Quadlet file (`jenkins.container`) can also be installed manually:

```bash
mkdir -p ~/.config/containers/systemd
cp jenkins.container ~/.config/containers/systemd/jenkins.container
systemctl --user daemon-reload
systemctl --user start jenkins.service
```

### Manage the service

| Action | Command |
|--------|---------|
| Start  | `systemctl --user start jenkins.service` |
| Stop   | `systemctl --user stop jenkins.service` |
| Restart| `systemctl --user restart jenkins.service` |
| Status | `systemctl --user status jenkins.service` |
| Logs   | `journalctl --user -u jenkins.service -f` |

---

## Run with Docker (legacy)

```bash
docker build -t jenkins:jcasc .
docker run --name jenkins --rm -p 8080:8080 -v jenkins_home:/var/jenkins_home jenkins:jcasc
```
