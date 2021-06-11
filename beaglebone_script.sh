# This script file purge the unwanted proccess and install the dependencies,z-ware and zipgateway
# NOTE : do not use the sudo permission
# Run only the --> bash beaglebone_script.sh <iotfrmwrok executable name> <zwave app executable name>
# we have to add the booting_script.sh give the inputs on run time. info is present in booting_script.sh.


#Purge the unwanted process
echo y | sudo apt-get purge c9-core-installer
echo y | sudo apt-get purge bonescript  
echo y | sudo apt-get purge nodejs 
echo y | sudo apt-get purge nginx 
echo y | sudo apt-get purge nginx-full
echo y | sudo apt-get autoremove 
echo y | sudo apt-get autoclean 
echo "******************************************************************************PURGING script is over*********************************************************************"

sudo cp /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
sleep 2s
echo "*******************************************************************************set time zone******************************************************************************"

#installation 
sudo apt-get update -y
echo "******************************************************************************update is over*********************************************************************"

sudo apt-get install radvd -y
sudo apt-get purge c9-core-installer -y
echo "******************************************************************************radvd is over*********************************************************************"

sudo apt-get --fix-broken install -y
echo "******************************************************************************--fix-break script is over*********************************************************************"
sudo apt-get install libmosquitto-dev -y
echo "******************************************************************************libmosqutto is over*********************************************************************"
sudo apt-get install mosquitto-dev -y
sudo apt-get install mosquitto-clients -y
echo "******************************************************************************mosqutto-dev script is over*********************************************************************"

sudo mkdir /medha_gateway
sudo mkdir /medha_gateway/local_server
echo "******************************************************************************permission changing**-****************************************************************************** "
sudo chmod +x iot_frmwrk*
sudo chmod +x zwave_app*
sudo chmod +x firmware_update_arm script_failed script_success software_update.sh cron_job hard_reset_arm
sudo chmod +x $(pwd)/config_change/config

sudo mv -f $(pwd)/iot_frm* zwave_app* app.cfg cmd_class.cfg zwave_device_rec.txt hard_reset_arm cron_job rm_boot_app.sh firmware_update_arm hard_reset_arm script_failed script_success software_update.sh version config_change/ /medha_gateway

sudo mv $(pwd)/medha_gateway /etc/logrotate.d/
sudo chown root:root /etc/logrotate.d/medha_gateway
#installing the zipgateway
echo "*******************************************************************************installing zip gateway**************************************************************************"
sudo dpkg -i $(pwd)/Z_wave_intall_beaglebone/zipgateway-7.15.04-Linux-stretch-armhf.deb 
sudo apt-get --fix-broken install -y

#installing the zware
echo "*******************************************************************************unpacking the zwave tar file*********************************************************************"

tar -xf $(pwd)/Z_wave_intall_beaglebone/zware-7.15.4-rpi.tar.gz -C $(pwd)/Z_wave_intall_beaglebone/

echo "*******************************************************************************installing the  zware****************************************************************************"
bash $(pwd)/Z_wave_intall_beaglebone/zware-7.15.4-rpi/install.sh  /medha_gateway/local_server

echo "******************************************************************************starting the zip gateway****************************************************************************"
#sudo systemctl enable zipgateway.service
sudo systemctl start zipgateway.service

echo "******************************************************************************starting the z-ware*********************************************************************************"
#sudo systemctl enable zware-service.service
sudo systemctl start zware-service.service
echo "******************************************************************************booting script**************************************************************************************"
sudo bash $(pwd)/booting_script.sh iot_frmwrk
sudo bash $(pwd)/booting_script.sh zwave_app
sudo bash $(pwd)/booting_script.sh firmware_update_arm

#sudo rm -rf $(pwd)/booting_script.sh Z_wave_intall_beaglebone beaglebone_script.sh ../bb*
echo "*****************************************************************************chnage the configuration******************************************************************************"

cd /medha_gateway/config_change && sudo ./config
#sudo ./config
#sudo rm -rf $(pwd)/booting_script.sh Z_wave_intall_beaglebone beaglebone_script.sh ../bb*

echo "****************************************************************************reboot*************************************************************************************************"
#sudo rm -rf /medha_gateway/avahi-daemon.conf1 /medha_gateway/mosquitto.conf1 /medha_gateway/config
#sudo rm -rf /medha_gateway/config_change/
#sudo chmod o+w /etc/crontab
#sudo echo "*/30 * * * * root sudo service zwave_app restart" >> /etc/crontab
#sudo chmod o-w /etc/crontab
sudo rm -rf /home/debian/*
sleep 3s
sudo reboot
