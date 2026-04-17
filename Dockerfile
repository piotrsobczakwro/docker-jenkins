FROM jenkins/jenkins:lts-jdk21

# Skip initial setup wizard
ENV JAVA_OPTS=-Djenkins.install.runSetupWizard=false

# Default JCasC config path – override or mount a file here to apply
# Configuration as Code at startup (used by docker-compose).
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml

# Install plugins using the official Jenkins Plugin CLI (replaces deprecated install-plugins.sh)
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
EXPOSE 8080


