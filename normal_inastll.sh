# This script file purge the unwanted proccess and install the dependencies,z-ware and zipgateway
# NOTE : do not use the sudo permission
# Run only the --> bash beaglebone_script.sh <iotfrmwrok executable name> <zwave app executable name>
# we have to add the booting_script.sh give the inputs on run time. info is present in booting_script.sh.
sudo service iot_frmwrk stop
sudo service zwave_app stop
sudo service zware-service stop
sudo service zipgateway stop
sudo systemctl disable zware-service
sudo bash rm_boot_app.sh iot_frmwrk zwave_app

echo y | sudo apt-get purge zipgateway

sudo mkdir /medha_gateway
sudo mkdir /medha_gateway/local_server
echo "******************************************************************************permission changing**-****************************************************************************** "
sudo chmod +x iot_frmwrk*
sudo chmod +x zwave_app*

sudo mv -f $(pwd)/iot_frm* zwave_app* app.cfg cmd_class.cfg zwave_device_rec.txt hard_reset_arm cron_job rm_boot_app.sh config_change/ /medha_gateway

#installing the zipgateway
echo "*******************************************************************************installing zip gateway**************************************************************************"
sudo dpkg -i $(pwd)/Z_wave_intall_beaglebone/zipgateway-7.15.02-Linux-stretch-armhf.deb 
sudo apt-get --fix-broken install -y

#installing the zware
echo "*******************************************************************************unpacking the zwave tar file*********************************************************************"

tar -xf $(pwd)/Z_wave_intall_beaglebone/zware-7.15.2-rpi.tar.gz -C $(pwd)/Z_wave_intall_beaglebone/

echo "*******************************************************************************installing the  zware****************************************************************************"
bash $(pwd)/Z_wave_intall_beaglebone/zware-7.15.2-rpi/install.sh  /medha_gateway/local_server

echo "******************************************************************************starting the zip gateway****************************************************************************"
#sudo systemctl enable zipgateway.service
sudo systemctl start zipgateway.service

echo "******************************************************************************starting the z-ware*********************************************************************************"
#sudo systemctl enable zware-service.service
sudo systemctl start zware-service.service
echo "******************************************************************************booting script**************************************************************************************"
sudo bash $(pwd)/booting_script.sh $1 iot_frmwrk
sudo bash $(pwd)/booting_script.sh $2 zwave_app

sudo rm /etc/init.d/zware-service
sudo mv zware-service /etc/init.d/

sudo rm -rf $(pwd)/booting_script.sh Z_wave_intall_beaglebone beaglebone_script.sh ../bb*
echo "*****************************************************************************chnage the configuration******************************************************************************"
cd /medha_gateway/config_change/ && sudo ./config
echo "****************************************************************************reboot*************************************************************************************************"
sudo rm -rf /medha_gateway/config_change/

sleep 3s
sudo reboot
