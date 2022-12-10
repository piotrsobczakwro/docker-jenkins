# install java
sudo yum -y install java-11-openjdk-devel

sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

sudo yum -y install wget
sudo yum -y install git
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo

# install jenkins
sudo yum -y install jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# open port for 8080
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-all

sudo  cat /var/lib/jenkins/secrets/initialAdminPassword
