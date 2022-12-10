# Jenkins Notes:

## Links:
https://www.jenkins.io/doc/book/managing/plugins/
https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.5/


## JENKINS_HOME
```
${JENKINS_HOME}
 +- config.xml     (jenkins root configuration)
 +- *.xml          (other site-wide configuration files)
 +- userContent    (files in this directory will be served under your http://server/userContent/)
 +- fingerprints   (stores fingerprint records)
 +- nodes          (slave configurations)
 +- plugins        (stores plugins)
 +- secrets        (secretes needed when migrating credentials to other servers)
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
				 

## Restart Jenkins manually.
To restart Jenkins manually:

`(jenkins_url)/safeRestart` - Allows all running jobs to complete. New jobs will remain in the queue to run after the restart is complete.

`(jenkins_url)/restart` - Forces a restart without waiting for builds to complete.



docker run --name jenkins --rm -p 8080:8182 jenkins:jcasc
