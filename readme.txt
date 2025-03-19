git clone https://github.com/rahildevops/vagrantFile.git

install the following on your laptop
--------------------------------------
 1. Install chocolatey from the instructions given in the link below 
	https://chocolatey.org/docs/installation
2. run the following command on powershell
	choco install virtualbox --version=7.1.4 -y
	choco install vagrant --version=2.4.3 -y
	choco install git -y

3. make sure to maintain following structure 
	a. all the files to be placed under D:\VM\vagrant
	b. software idm = D:\binaries\software\idm
	d. software  am = D:\binaries\software\am

4. add following into your host file.

	192.168.56.42  ds.afiyan.com  login.afiyan.com
	192.168.56.82  keycloak.afiyan.com keycloak
	192.168.56.43  idm.afiyan.com
	
4. Access URL's
	a. idm http://idm.afiyan.com:8080/
