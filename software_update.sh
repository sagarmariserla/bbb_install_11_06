#!/bin/bash

sudo sed -i '/software_update.sh/d' /etc/crontab
sudo echo "*/2 * * * * root sudo bash /medha_gateway/software_update.sh" >>/etc/crontab

old=`cat /medha_gateway/version`

sudo git clone https://github.com/sagarmariserla/software_update

sudo tar -xf $(pwd)/software_update/*.tar.xz -C $(pwd)/software_update

CMD=$(ls $(pwd)/software_update/ | grep software_update)
echo $CMD

        if [ `echo $CMD | grep -c "software_update" ` -gt 0 ]
        then
		echo ""
 		echo "successfully download the package"
        fi

val=`cat $(pwd)/software_update/*/version`

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$old"; }

if version_gt $old $val; then
	echo "==========================================="
	echo "old package vresion is $old"
	echo "New package is available version is $val "
	sudo $(pwd)/script_success
	echo "script_success responce send sleep 3s"
	sleep 3s
	echo "Now installing the new version Please wait......."

       # echo "$old is less than $val"
	# crontab -l | grep -v '/bin/bash /home/debian/software_update.sh'  | sort | uniq | crontab -
	#(crontab -l ; echo "*/2 * * * * /bin/bash /home/debian/software_update.sh $val") | sort | uniq | crontab -

CMD1=$(ls $(pwd)/software_update/*/ | grep iot_frmwrk)
echo $CMD1

	if [ `echo $CMD1 | grep -c "iot_frmwrk" ` -gt 0 ]
	then
		echo "iot_frmwrk"
		sudo service iot_frmwrk stop
		sudo chmod +x $(pwd)/software_update/*/iot_frmwrk
		echo "enter ctrl+c"
		#sudo rm /medha_gateway/iot_frmwrk
		sudo cp $(pwd)/software_update/*/iot_frmwrk /medha_gateway
		#sudo service iot_frmwrk start
	fi

CMD2=$(ls $(pwd)/software_update/*/ | grep zwave_app)
echo $CMD2

	if [ `echo $CMD2 | grep -c "zwave_app" ` -gt 0 ]
	then
 		 echo "zwave_app"
       		 sudo service zwave_app stop
       		# sudo rm /medha_gateway/zwave_app
		echo "enter ctrl+c"
	       	 sudo chmod +x $(pwd)/software_update/*/zwave_app
        	 sudo cp $(pwd)/software_update/*/zwave_app /medha_gateway
      		 sudo service zwave_app start
	 fi
	
	sudo cp $(pwd)/software_update/*/version /medha_gateway
	sudo rm -rf $(pwd)/software_update
	sudo service iot_frmwrk start
	echo "update is completed"
	sudo sed -i '/software_update.sh/d' /etc/crontab
	#sudo $(pwd)/script_success

else

	sudo rm -rf $(pwd)/software_update
	echo ""
	echo "already packages are updated version is $old "
	sudo $(pwd)/script_failed
	sudo sed -i '/software_update.sh/d' /etc/crontab
	exit

fi



