#!/bin/bash -e

on_chroot << EOF

echo "${DOCKER_REPO_PASS}" | docker login -u "${DOCKER_REPO_USER}" "${DOCKER_REPO_URL}" --password-stdin;
cp -r /root/.docker /home/pi/.docker
chown -R pi:pi /home/pi/.docker
EOF

cat > "${ROOTFS_DIR}/etc/NetworkManager/NetworkManager.conf" << EOF

[main]
plugins=ifupdown,keyfile
dhcp=internal

[ifupdown]
managed=true
EOF

# Allow SPI
sed -i '/dtparam=spi/s/^#//g' ${ROOTFS_DIR}/boot/config.txt

# Allow I2C
sed -i '/dtparam=i2c_arm/s/^#//g' ${ROOTFS_DIR}/boot/config.txt
grep -q '^i2c-dev' ${ROOTFS_DIR}/etc/modules || echo 'i2c-dev' >> ${ROOTFS_DIR}/etc/modules

# ADD RTC
grep -q '^dtoverlay=i2c-rtc,ds1307' ${ROOTFS_DIR}/boot/config.txt || echo 'dtoverlay=i2c-rtc,ds1307' >> ${ROOTFS_DIR}/boot/config.txt

# Remove wlan0 from dhcpcd
grep -q '^denyinterfaces wlan0' ${ROOTFS_DIR}/etc/dhcpcd.conf || echo 'denyinterfaces wlan0' >> ${ROOTFS_DIR}/etc/dhcpcd.conf
grep -q '^denyinterfaces eth0' ${ROOTFS_DIR}/etc/dhcpcd.conf || echo 'denyinterfaces eth0' >> ${ROOTFS_DIR}/etc/dhcpcd.conf
