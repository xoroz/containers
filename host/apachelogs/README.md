This to allow access to apache logs to a local users via SFTP 

The script setup.sh will take care of mapping log directory to home folder of user alogs

For it to work please first create and configure
1) the user alogs 
2) setup ssh entry
3) install bindfs

NOTE:
The setup.sh could run every 15m to check and update mountpoint as container volumes are created 


# 1)setup user alogs
groupadd sftponly 
useradd -d /home/sftproot/alogs -g sftponly -G www-data  -u 2020 -s /nobin/noaccess alogs
passwd alogs
mkdir -p /home/sftproot/alogs/home 
chown root.root /home/sftproot/alogs
chown alogs:sftponly /home/sftproot/alogs/home


# 2)setup the ssh entry into /etc/ssh/sshd_config
Match Group sftponly
	ChrootDirectory /home/sftproot/%u
	ForceCommand internal-sftp
	AllowTcpForwarding no
# 3)install bindsf
apt install bindfs

