#!/bin/bash

# sample call 
# Export_ImportAsset.sh export

# update below parametres before running the BAT file
# Required for export path only
export es4ServerIP=10.42.80.249
export es4Serverport=8080

# Required for import path only
export jee63ServerIP=10.42.80.249
export jee63Serverport=8080

# ES4 CRX and doc services admin password
export es4CRXPassword=admin
export es4LCPassword=password

# AEM forms JEE CRX admin's password
export jeeCRXPassword=admin

exportFromES4 ()
{
	# Export from ES4:
	# Install pre-migration utility
	curl -u admin:$es4CRXPassword -F file=@"CM-PRE-MIGRATION.zip" -F name="cm--p#igration-package" -F force=true -F install=true http://$es4ServerIP:$es4Serverport/lc/crx/packmgr/service.jsp
	
	# Run Pre-migration
	curl -u administrator:$es4LCPassword http://$es4ServerIP:$es4Serverport/lc/content/changeType.html?actionType=1
	
	# Import an existing package with predefined filter: 
	curl -u admin:$es4CRXPassword -F file=@"FM_package.zip" -F name="FM_package" -F force=true -F install=false http://$es4ServerIP:$es4Serverport/lc/crx/packmgr/service.jsp

	# Build it on the ES4 server
	curl -u admin:$es4CRXPassword -X POST http://$es4ServerIP:$es4Serverport/lc/crx/packmgr/service/.json/etc/packages/my_packages/FM_package.zip?cmd=build

	# Download the package locally as ExportedFMpkg.zip
	curl -u admin:$es4CRXPassword http://$es4ServerIP:$es4Serverport/lc/etc/packages/my_packages/FM_package.zip>ExportedFMpkg.zip

}

importTo63()
{
	# Import and install on 6.3 server :
	# Import the package exported from ES4: 
	curl -u admin:$jeeCRXPassword -F file=@"ExportedFMpkg.zip" -F name="ExportedFMpkg" -F force=true -F install=true http://$jee63ServerIP:$jee63Serverport/lc/crx/packmgr/service.jsp
}

args_count_wrong ()
{
echo "Exactly one command line argument should be passed, i.e import or export"
}

args_count_ok ()
{
export Operation=$1
echo $Operation
if [ "$Operation" = "export" ]
then
exportFromES4
fi

if [ "$Operation" = "import" ] 
then
importTo63
fi
}


if [ $# -eq 0 ]
then
args_count_wrong
else
args_count_ok "$1"
fi
