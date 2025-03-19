

install the following on your laptop
--------------------------------------
 1. Install chocolatey from the instructions given in the link below 
	https://chocolatey.org/docs/installation
2. run the following command on powershell
	choco install virtualbox --version=7.1.4 -y
	choco install vagrant --version=2.4.3 -y
	choco install git -y

3. Make the following directory structure

	a. mkdir -p /d/VM /d/binaries/software/idm /d/binaries/software/am

4. move the following 
        
	a. mv vagrantFile /d/VM/vagrant
	b 


5. add following into your host file.

	192.168.56.42  ds.afiyan.com  login.afiyan.com
	192.168.56.82  keycloak.afiyan.com keycloak
	192.168.56.43  idm.afiyan.com

6. To install idm do the following 
	
	a. move your idm binaries to /d/binaries/software/idm
 	b. cd /d/VM/vagrant/forgerockidm
	c. vagrant up
	c. wait for the VM to start.
	d. http://idm.afiyan.com:8080/
	e. openidm-admin\openidm-admin
	
5. Access URL's
	a. idm http://idm.afiyan.com:8080/


6. credentials 
	
