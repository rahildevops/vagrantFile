
---------------------------------------------------------
		Start one time activity
---------------------------------------------------------
 1. Install chocolatey from the instructions given in the link below 
	https://chocolatey.org/docs/installation
 2. run the following command on powershell
	choco install virtualbox --version=7.1.4 -y
	choco install vagrant --version=2.4.3 -y
	choco install git -y

 3. git clone https://github.com/rahildevops/vagrantFile.git

 4. mkdir -p /d/VM

 5. mv vagrantFile /d/VM/vagrant

---------------------------------------------------------
		End one time activity
---------------------------------------------------------


---------------------------------------------------------
		Install AM
---------------------------------------------------------

1. Download ForgeRock AM and DS
2. mkdir -p /d/binaries/software/am
3. copy the AM and DS binaries to  /d/binaries/software/am
4. update your base machine hosts file and add following entry
	192.168.56.42 login.afiyan.com
5. cd /d/VM/vagrant/forgerock
6. vagrant up
7. open the URL in your local https://login.afiyan.com/login
8. enter amadmin\SecAuth0

---------------------------------------------------------
		End of AM Install
---------------------------------------------------------


---------------------------------------------------------
		Install IDM
---------------------------------------------------------

1. Download ForgeRock IDM 
2. mkdir -p /d/binaries/software/idm
3. copy the idm  /d/binaries/software/am
4. update your base machine hosts file and add following entry
	192.168.56.42 login.afiyan.com
5. cp /d/VM/vagrant/forgerockidm/openidm.service /d/binaries/software/idm
5. cd /d/VM/vagrant/forgerockidm
6. vagrant up
7. open the URL in your local https://login.afiyan.com/login
8. enter openidm-admin\openidm-admin

---------------------------------------------------------
		End one time activity
---------------------------------------------------------


3. Make the following directory structure

	a. mkdir -p /d/VM /d/binaries/software/idm /d/binaries/software/am

4. move the following 
        
	a. 
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
	
