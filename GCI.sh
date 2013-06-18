#!/bin/sh

############################################
############################################
#  Gather Computer Inventory
############################################
############################################
#
#	Created By Dany-F, June 2013
#


logFilePath="/Library/Logs/Dany-GCI.log";

####################
#	START FUNCTIONS
####################
## Log File Path

theLog ()
{
	
	if [ ! -f "${logFilePath}" ]; then
		/usr/bin/touch "${logFilePath}";
		/usr/sbin/chown root:admin "${logFilePath}";
		/bin/chmod 775 "${logFilePath}";
	fi
	
	echo "`date`	-	${1}" >> "${logFilePath}";
	#echo "`date`	-	${1}";
}

removeCommas ()
{
	
	cleanedText=`echo "$1" | tr -d "," "[:space:]"`;
	echo "$cleanedText";
}
####################
#	END FUNCTIONS
####################

#######################################
# Setup Global Variables to PLIST
#######################################
/usr/bin/defaults write /Library/Preferences/com.danyf.gci "GCIVersion" -string "1.0kc";


cn=`hostname -s`;

####################################
### START GENERATE COMPUTER INVENTORY
####################################
## Empty Log File
/bin/rm -f "${logFilePath}";


theLog "Starting Inventory";
## Get Mac OSX Version
theLog "Getting Computer OS Version";
osVersion=`uname -r | cut -d '.' -f 1`;
osSubVersion=`uname -r | cut -d '.' -f2`;

if [ $osVersion -lt 8 ]; then
	theLog "Unsupported Mac OSX Version";
	theLog "I will Quit Now.";
	exit 0;


elif [ $osVersion -eq 8 ]; then
	## This Computer is running 10.4
	theLog "Mac OSX Version 10.4.${osSubVersion}";
	osVersionFull="Mac OSX Version 10.4.${osSubVersion}";
		
elif [ $osVersion -eq 9 ]; then
	## This Computer is running 10.5
	theLog "Mac OSX Version 10.5.${osSubVersion}";
	osVersionFull="Mac OSX Version 10.5.${osSubVersion}";
	
elif [ $osVersion -eq 10 ]; then
	## This Computer is running 10.6
	theLog "Mac OSX Version 10.6.${osSubVersion}";
	osVersionFull="Mac OSX Version 10.6.${osSubVersion}";
	
elif [ $osVersion -eq 11 ]; then
	## This Computer is running 10.7
	theLog "Mac OSX Version 10.7.${osSubVersion}";
	osVersionFull="Mac OSX Version 10.7.${osSubVersion}";
	
elif [ $osVersion -eq 12 ]; then
	## This Computer is running 10.8	
	theLog "Mac OSX Version 10.8.${osSubVersion}";
	osVersionFull="Mac OSX Version 10.8.${osSubVersion}";
elif [ $osVersion -eq 13 ]; then
	## This Computer is running 10.9	
	theLog "Mac OSX Version 10.9.${osSubVersion}";
	osVersionFull="Mac OSX Version 10.9.${osSubVersion}";
fi



## Ethernet MAC Address
theLog "Getting Ethernet MAC Address...";
computerID=`/sbin/ifconfig en0 | awk '/ether /' | cut -d " " -f 2 | tr '[:lower:]' '[:upper:]'`;
theLog "$computerID";


## Get Computer Serial Number
theLog "Getting Computer Serial Number...";
computerSerial=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep "Serial Number" | cut -d ":" -f 2 | cut -d " " -f 2`;

theLog "$computerSerial";

## Setting Serial Number to Field #1 of ARD
currentInfo=`/usr/bin/defaults read /Library/Preferences/com.apple.RemoteDesktop "Text1"`;

if [ "${computerSerial}" != "${currentInfo}" ]; then
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -computerinfo -set1 -1 "${computerSerial}";
fi


## Get Asset Tag
theLog "Getting Asset Tag...";
AssetTagField=`/usr/bin/defaults read /Library/Preferences/com.apple.RemoteDesktop "Text2"`;

if [ -n "$AssetTagField" ]; then
	
	## Write to NVRAM
	/usr/sbin/nvram "AssetTag=${AssetTagField}";
	
	## Save to PLIST
	/usr/bin/defaults write /Library/Preferences/com.gci.clientInfo "DistrictNumber" -string "${fieldDistrictNumber}";
	
	theLog "$AssetTagField";
	AssetTag="$AssetTagField";
else
	theLog "Asset Tag Not Setup";
	AssetTag="";
fi


## Get Apple Model
theLog "Getting Apple Computer Model Name...";
if [ $osVersion -eq 8 ]; then
	computerModel=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep "Machine Name:" | cut -d ':' -f 2 | cut -c 2-`;

else
	computerModel=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep "Model Name:" | cut -d ':' -f 2 | cut -c 2-`;

fi
theLog "$computerModel";

## Get Computer Memory
theLog "Getting Computer Memory Size...";
computerMemory=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep "Memory:" | cut -d ':' -f 2 | cut -c 2-`;
theLog "$computerMemory";

## Get Computer CPU Type
theLog "Getting Computer CPU Type";

if [ $osVersion -eq 8 ]; then
	computerCPUType=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep "CPU Type:" | cut -d ':' -f 2 | cut -c 2-`;
else
	computerCPUType=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep "Processor Name:" | cut -d ':' -f 2 | cut -c 2-`;
fi
theLog "$computerCPUType";


## Get Computer CPU Speed
theLog "Getting Computer CPU Speed...";
if [ $osVersion -eq 8 ]; then
	computerCPUSpeed=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep "CPU Speed:" | cut -d ':' -f 2 | cut -c 2-`;
else
	computerCPUSpeed=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep "Processor Speed:" | cut -d ':' -f 2 | cut -c 2-`;
fi
theLog "$computerCPUSpeed";

## Get Hard Drive Size
theLog "Getting Hard Drive Size...";
hdSize=`/usr/sbin/diskutil info /dev/disk0 | /usr/bin/grep "Total Size:" | awk '{print $3 " " $4}'`;
theLog "${hdSize}";

## Get IP Addresses

en0=`/usr/sbin/ipconfig getifaddr en0 2>&1` ;
en1=`/usr/sbin/ipconfig getifaddr en1 2>&1`;

if [ "$en0" = "get if addr en0 failed, (os/kern) failure" ]; then 
en0="";
else
	theLog "$en0";
fi

if  [ "$en1" = "get if addr en1 failed, (os/kern) failure" ]; then 
en1="";
else
	theLog "$en1";
fi


## Get Computer Names
theLog "Getting Computer Host Name";
hostName=`/usr/sbin/scutil --get LocalHostName`;
theLog "$hostName";

theLog "Getting Computer Name";
computerName=`/usr/sbin/scutil --get ComputerName`;
theLog "$computerName";


## Get Name of Default Printer
theLog "Getting Default Printer...";
getPrinterInfo=`/usr/bin/lpstat -d | /usr/bin/grep ":"`;
defaultPrinter=`echo "${getPrinterInfo}" | /usr/bin/sed -E 's/^.+: //'`;

theLog "${defaultPrinter}";


## Get Flash Version
theLog "Getting Flash Plugin Version...";

if [ -d "/Library/Internet Plug-Ins/Flash Player.plugin" ]; then
	flashVersion=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/Info" "CFBundleShortVersionString"`;
	theLog "Flash Version is: ${flashVersion}";
else
	flashVersion="Not Installed";
	theLog "Flash Plugin not installed.";
fi


## Screen Resolution
theLog "Getting Screen Resolution...";

screenWidth=`defaults read /Library/Preferences/com.apple.windowserver | grep -w "Width" | head -n 1 | tr -cd "[:digit:]"`;
screenHeight=`defaults read /Library/Preferences/com.apple.windowserver | grep -w "Height" | head -n 1 | tr -cd "[:digit:]"`;
screenResolution="${screenWidth} x ${screenHeight}";
screenResolutionTest=`echo "$screenResolution" | tr -cd "[:digit:]"`;

### If Blank, then try from system profiler
if [ -z "$screenResolutionTest" ]; then
	screenResolution=`/usr/sbin/system_profiler SPDisplaysDataType | /usr/bin/grep "Resolution:" | cut -d ":" -f2 | tr -d "[:space:]"`;
fi



theLog "Screen Resolution: ${screenResolution}";

## Inventory Method
theLog "Setting GCI version";
gciVersion=`/usr/bin/defaults read /Library/Preferences/com.dany.gci "GCIVersion"`;
theLog "GCI Version: ${gciVersion}";

## Get Time Stamp for File
timeStamp=`date +"%m_%d_%Y - %H_%M_%S"`;


## Get FireFox Version

theLog "Getting Firefox Version";
if [ -d "/Applications/Firefox.app" ]; then
	firefoxVersion=`/usr/bin/defaults read "/Applications/Firefox.app/Contents/Info" "CFBundleShortVersionString"`;
else
	firefoxVersion="NONE";
fi

theLog "Firefox: ${firefoxVersion}";

## Get Java Version

/usr/libexec/java_home > /dev/null 2>&1;

if [ $? == 0 ]; then
	javaVersion=`/usr/bin/java -version 2>&1 | /usr/bin/grep "java version" | awk '{print $3}' | tr -d \"`;
else
	javaVersion="NONE";
fi

theLog "Java: ${javaVersion}";


## Get Acrobat Version

acrobatVersion="";

if [ -f "/usr/bin/find" ]; then
	acrobatVersion=`/usr/bin/find "/Applications" -iname "Adobe Reader.app" -maxdepth 2 -type d -exec /usr/bin/defaults read "{}/Contents/Info" CFBundleShortVersionString \;`;
else
	acrobatVersion="";
fi
theLog "Acrobat: ${acrobatVersion}";


## Get OS Update

osUpdate="";
if [ -f "/Library/Preferences/com.apple.SoftwareUpdate.plist" ]; then
	osUpdate=`/usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate "LastSuccessfulDate" | /usr/bin/awk '{print $1" "$2}'`;
fi
theLog "OS Update: ${osUpdate}";


### Get Munkii Info
munkiPFile="/usr/local/munki/munkilib/version";
munkiVersion="";

if [ -f "${munkiPFile}.plist" ]; then
	munkiVersion=`defaults read "/usr/local/munki/munkilib/version" CFBundleShortVersionString`;
	
	isImac=`/bin/hostname -s | /usr/bin/grep -i "\-imac"`;
	
	if [ $? -eq 0 ]; then
		/usr/bin/defaults write /Library/Preferences/ManagedInstalls ClientIdentifier -string "snl_student_imacs";
	fi
	/usr/bin/defaults write /Library/Preferences/ManagedInstalls SoftwareRepoURL "http://10.195.239.59/munki_repo";
	/usr/bin/defaults write /Library/Preferences/ManagedInstalls AppleSoftwareUpdatesOnly -bool NO;

fi


### Get Default Browser
safariVersion="";
safariPaths=`/usr/bin/mdfind 'kMDItemContentType == "com.apple.application-bundle" && kMDItemFSName = "Safari.app"'`;


for aSafari in `echo "${safariPaths}" | tr " " ";"`
do
	newPath=`echo "$aSafari" | tr ";"  " "`;
	plistPath="${newPath}/Contents/Info";
	
	if [ -f "${plistPath}.plist" ]; then
		version=`/usr/bin/defaults read "${plistPath}" "CFBundleShortVersionString"`;
		
		if [ -z "$safariVersion" ]; then
			safariVersion="Safari: ${version}";
		else
			safariVersion="${safariVersion} Safari: ${version}";
		fi
	fi
	
done;

theLog "${safariVersion}";



####################################
### END GATHER COMPUTER INFO
####################################


####################################
### START WRITE COMPUTER INFO
####################################


### Create GCI Folder
baseFolder="/Library/GCI";

if [ ! -d "$baseFolder" ]; then
	### Create base folder
	/bin/mkdir "$baseFolder";
	/usr/sbin/chown -R root:admin "$baseFolder";
	/bin/chmod -R 775 "$baseFolder";
fi


cleanCI=`echo "${computerID}" | tr ":" "_"`;
localPreference="${baseFolder}/${cleanCI}.txt";


theLog "Writing to local text file";
echo "HWAddress,SerialNumber,AssetTag,Model,OSVersion,RAM,CPUType,CPUSpeed,HDSize,ComputerName,ComputerHostName,EN0IPAddress,EN1IPAddress,DefaultPrinter,FlashVersion,TimeStamp,ScreenResolution,GCI_Version,firefoxVersion,javaVersion,acrobatVersion,lastOSUpdate,munkiVersion,safariVersion" > "$localPreference";
echo "${computerID},${computerSerial},${AssetTag},${computerModel},${osVersionFull},${computerMemory},${computerCPUType},${computerCPUSpeed},${hdSize},${computerName},${hostName},${en0},${en1},${defaultPrinter},${flashVersion},${timeStamp},${screenResolution},${gciVersion},${firefoxVersion},${javaVersion},${acrobatVersion},${osUpdate},${munkiVersion},${safariVersion}" >> "$localPreference";


####################################
### END WRITE COMPUTER INFO
####################################


theLog "Done Inventory";


exit 0;
