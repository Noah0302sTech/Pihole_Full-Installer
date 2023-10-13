#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x KeepAliveD-Installer-Noah0302sTech.sh && sudo bash KeepAliveD-Installer-Noah0302sTech.sh

#---------- Initial Checks & Functions
	#----- Check for administrative privileges
		if [[ $EUID -ne 0 ]]; then
			echo "This Script needs to be run with Root-Privileges! (sudo)"
			exit 1
		fi



	#----- Source of Spinner-Function: https://github.com/tlatsas/bash-spinner
			function _spinner() {
				# $1 start/stop
				#
				# on start: $2 display message
				# on stop : $2 process exit status
				#           $3 spinner function pid (supplied from stop_spinner)

				local on_success="DONE"
				local on_fail="FAIL"
				local white="\e[1;37m"
				local green="\e[1;32m"
				local red="\e[1;31m"
				local nc="\e[0m"

				case $1 in
					start)
						# calculate the column where spinner and status msg will be displayed
						let column=$(tput cols)-${#2}-8
						# display message and position the cursor in $column column
						echo -ne ${2}
						printf "%${column}s"

						# start spinner
						i=1
						sp='\|/-'
						delay=${SPINNER_DELAY:-0.25}

						while :
						do
							printf "\b${sp:i++%${#sp}:1}"
							sleep $delay
						done
						;;
					stop)
						if [[ -z ${3} ]]; then
							echo "spinner is not running.."
							exit 1
						fi

						kill $3 > /dev/null 2>&1

						# inform the user uppon success or failure
						echo -en "\b["
						if [[ $2 -eq 0 ]]; then
							echo -en "${green}${on_success}${nc}"
						else
							echo -en "${red}${on_fail}${nc}"
						fi
						echo -e "]"
						;;
					*)
						echo "invalid argument, try {start/stop}"
						exit 1
						;;
				esac
			}

			function start_spinner {
				# $1 : msg to display
				_spinner "start" "${1}" &
				# set global spinner pid
				_sp_pid=$!
				disown
			}

			function stop_spinner {
				# $1 : command exit status
				_spinner "stop" $1 $_sp_pid
				unset _sp_pid
			}



		#----- echoEnd
				function echoEnd {
					echo
					echo
					echo
				}



	#----- Refresh Packages
		start_spinner "Updating Package-Lists..."
			sudo apt update > /dev/null 2>&1
		stop_spinner $?
		echoEnd

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Variables
	ifaceName="eth0"
	uniSrc="192.168.6.8"
	uniPeer="192.168.6.9"
	virtIP="192.168.6.10"
	keepAlivedPW="KeepAlived1!"
	prio="50"



#----- Prompt for custom values
	#--- Interface Name
		read -p "Enter the Interface-Name (Most likely the primary of this Machine) [default: $ifaceName]: " input
		ifaceName=${input:-$ifaceName}

	#--- Unicast Source
		read -p "Enter the Unicast-Source-IP (IP of this Machine) [default: $uniSrc]: " input
		uniSrc=${input:-$uniSrc}

	#--- Unicast Destination
		read -p "Enter the Unicast-Destination-IP (IP of the other Machine) [default: $uniPeer]: " input
		uniPeer=${input:-$uniPeer}

	#--- Virtual IP
		read -p "Enter the virtual KeepAliveD-IP (The Highly-Availible-IP) [default: $virtIP]: " input
		virtIP=${input:-$virtIP}

	#--- Unbound PW
		read -p "Enter the KeepAliveD-Password (Needs to be the same on both Machines) [default: $keepAlivedPW]: " input
		keepAlivedPW=${input:-$keepAlivedPW}

	#--- Priority
		read -p "Enter the Priority of this Machine (Higher=Primary, Lower=Secondary) [default: $prio]: " input
		prio=${input:-$prio}
	echoEnd



#----- KeepAliveD
	#--- Install KeepAliveD
		start_spinner "Installing KeepAliveD..."
			apt install keepalived -y > /dev/null 2>&1
		stop_spinner $?

	#--- Install KeepAliveD
		start_spinner "Configuring KeepAliveD-Config..."
			echo "" > /etc/keepalived/keepalived.conf
			echo '#Primary
vrrp_instance VI_1 {
  state MASTER
  interface '$ifaceName'
  virtual_router_id 55
  priority '$prio'
  advert_int 1
  unicast_src_ip '$uniSrc'
  unicast_peer {
    '$uniPeer'
  }

  authentication {
    auth_type PASS
    auth_pass '$keepAlivedPW'
  }

  virtual_ipaddress {
    '$virtIP'
  }
}' | tee -a /etc/keepalived/keepalived.conf > /dev/null 2>&1
			stop_spinner $?

	#--- Enable
		start_spinner "Enabling KeepAliveD..."
			systemctl enable --now keepalived.service > /dev/null 2>&1
		stop_spinner $?

	#--- Status
		echo "KeepAliveD Status..."
			systemctl status keepalived.service
			sleep 1
	echoEnd





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#

#----- Variables
	folderVar=Pihole
	subFolderVar=KeepAlived
	shPrimaryVar=KeepAliveD-Installer-Noah0302sTech.sh

#----- Create Folders
	start_spinner "Creating Directories..."
		#--- /home/$SUDO_USER/Noah0302sTech
			if [ ! -d /home/$SUDO_USER/Noah0302sTech ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech > /dev/null 2>&1
			else
				echo "Directory /home/$SUDO_USER/Noah0302sTech is already present!"
			fi

		#--- Folder Variable
			if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar > /dev/null 2>&1
			else
				echo "Directory /home/$SUDO_USER/Noah0302sTech/$folderVar is already present!"
			fi

		#--- Sub Folder Variable
			if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar > /dev/null 2>&1
			else
				echo "Directory /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar is already present!"
			fi
	stop_spinner $?

#----- Move Bash-Script
	start_spinner "Moving $shPrimaryVar..."
		#--- Primary Script Variable
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar ]; then
				mv /home/$SUDO_USER/$shPrimaryVar /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar > /dev/null 2>&1
			else
				echo "The File /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar is already present!"
			fi
	stop_spinner $?