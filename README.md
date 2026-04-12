# Jenkins Notes

## Links
- https://www.jenkins.io/doc/book/managing/plugins/
- https://www.jenkins.io/doc/book/installing/docker/
- https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html

## Base image
This project uses `jenkins/jenkins:lts-jdk21` – the current Jenkins LTS release built on JDK 21.

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

## Run with Podman (recommended)

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
