[TOC]


# How do I get set up?

* get a machine (VM, your laptop, etc.) with port 80 open (firewalld, SELinux, security groups on AWS, etc.)
    * over web interface (http://aws.amazon.com/)
    * using cli
        * install awscli (http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
        * create IAM user and generate credentials (http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html)
        * attach the user you just created to the right access policies (http://docs.aws.amazon.com/IAM/latest/UserGuide/PermissionsAndPolicies.html)
* initial config
    * add your ssh key to .ssh/authorized_keys
    * generate ssh key for server, add it to bitbucket account
        * https://confluence.atlassian.com/display/BITBUCKET/Set+up+SSH+for+Git
    * install puppet (yum install puppet)
    * install git (yum install git)
* download and apply manifests from this git repo
    * clone this repo to /etc/puppet/modules/
    * install required puppet modules using a shell script from this repo (./install_modules.sh)
    * apply configuration to your machine: puppet apply site.pp | tee -a /var/log/puppet/apply_run.log
    * if you're getting errors, run the above command until you get no errors. This will be fixed in future releases.
* start Dynamic DNS service
    * put credentials and hostname in ddclient config at: '/etc/ddclient/ddclient.conf'
    * restart service: systemctl restart ddclient
* create SELinux policy for nginx:
    * http://superuser.com/questions/809527/nginx-cant-connect-to-uwsgi-socket-with-correct-permissions
* open webrowser and go to: technical-analysis.sytes.net
    * if something is not working restart nginx and uwsgi



# Work notes

## notes
*  example42 modules are rubish
* enabling repos
    * yum repolist all
    * yum-config-manager --enable epel
## algorithm design

algorithm should be self-evaluating (it should check results and adapt), it should use data from the last 3 months to learn


## great examples of Docker configurations

https://registry.hub.docker.com/u/lbracken/flask-uwsgi/

https://registry.hub.docker.com/u/apierleoni/flask-uwsgi/dockerfile/

https://registry.hub.docker.com/u/p0bailey/docker-flask/

## nginx-uwsgi communication

set SELinux for nginx-uwsgi communication, use tcp sockets for nginx-uwsgi (cleaner design)



nginx config:


```
#!python


upstream uwsgicluster {
  # server unix:///tmp/uwsgi.sock;
  # server 192.168.1.235:3031;
  # server 10.0.0.17:3017;
  server 127.0.0.1:8080;
}


server {
  listen *:80;
  server_name           technical-analysis.sytes.net;

  set $maintenance "off";
  if ($maintenance = "on") {
      return 503;
  }
  # index  index.html index.htm index.php;

  access_log            /var/log/nginx/technical-analysis.sytes.net.access.log combined;
  error_log             /var/log/nginx/technical-analysis.sytes.net.error.log;

  location / {
    root      /usr/share/nginx/technical-analysis.sytes.net/;
    include uwsgi_params;
    uwsgi_pass uwsgicluster;
  }
}

```


uwsgi config:

http://vladikk.com/2013/09/12/serving-flask-with-nginx-on-ubuntu/

https://www.digitalocean.com/community/tutorials/how-to-deploy-python-wsgi-applications-using-uwsgi-web-server-with-nginx

http://blog.cnicodeme.com/how-to-setup-a-flask-project-with-uwsgi-and-nginx

http://blog.collabspot.com/2012/08/14/setting-up-nginx-uwsgi-python-ubuntu-12-04/



# Changelog #

## moved from Trello to Bitbucket ##
* why moved? Trello does not have place to put a lot of text. Authors say to use cards, but structure provided here (or github) much better reflects software projects. Besides everything is in one place, code, documentation, etc. Also, this is how shared projects are being built so it's better use industry standards.
* wiki on bitbucket is super basic which is very annoying, e.g. no table of contents containing all pages (only for Creole)
* wiki is not stored together with other files. Move wiki to Readme, don't use masters as production. Instead create branch production - masters will be merged to it to have a clean workflow
