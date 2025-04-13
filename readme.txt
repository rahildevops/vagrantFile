
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
6. cp /d/VM/vagrant/forgerock/server.xml  /d/binaries/software/am/
7. cp /d/VM/vagrant/forgerock/config.properties  /d/binaries/software/am/
6. vagrant up

7. login to  AM console
	a. open the URL in your local https://login.afiyan.com:8443/login
	b. enter amadmin\SecAuth0
8. Login to directory server
	
	a. Download Apache directory studio.
	b. connection details
		ssl is true
		hostname login.afiayn.com
		username uid=admin
		password SecAuth0

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
6. cd /d/VM/vagrant/forgerockidm
7. vagrant up
8. open the URL in your local https://idm.afiyan.com
8. enter openidm-admin\openidm-admin

---------------------------------------------------------
		End of IDM install
---------------------------------------------------------



---------------------------------------------------------
		Install KeyCLoak
---------------------------------------------------------


1. update your base machine hosts file and add following entry
	192.168.56.82 keycloak.afiyan.com
6. cd /d/VM/vagrant/keyclock
7. vagrant up
8. open the URL in your local 192.168.56.82:8080
8. enter admin\SecAuth0

---------------------------------------------------------
		End of KeyCLoak install
---------------------------------------------------------



---------------------------------------------------------
		Install Platform
---------------------------------------------------------

1. Download ForgeRock software
	AM-7.5.1.zip
    apache-tomcat-9.0.102.tar.gz
	DS-7.5.1.zip
	IDM-7.5.0.zip
	PingGateway-2024.11.0.zip
	PlatformUI-7.5.1.0610.zip
	
2. Copy the binaries folder to d drive

3. Copy all the software to the folder D:\binaries\software\platform

4. cp /d/vm/vagrant/files-Needed/* /d/binaries/software/platform/

5. cp -r /d/vm/vagrant/ig-config /d/binaries/software/platform/

6. mkdir /d/VM/vagrant-config and add it you environment variable

6. mkdir /d/VM/Vamware and update in your VM-box setting file-> preferences --> add the location

7. make following entry to your system host file

192.168.56.43   admin.example.com
192.168.56.43   am.example.com
192.168.56.43   directory.example.com
192.168.56.43   enduser.example.com
192.168.56.43   login.example.com
192.168.56.43   openidm.example.com
192.168.56.43   platform.example.com  

8. cd /d/vm/vagrant/forgerockplatform

9. vagrant up


Not needed 

10. setting up frodo for local --> user powershell
frodo conn save `
  "https://platform.example.com:9443/am" `
  "Amadmin" `
  "SecAuth0" `
  --idm-host "https://platform.example.com:9443/openidm" `
  --insecure `
  --no-validate

	 


---------------------------------------------------------
		End of Platform install
---------------------------------------------------------