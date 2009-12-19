#!/bin/bash

echo "Where is the new system? (default /mnt/dice)"
read input_path

umount $input_path/dev
umount $input_path/proc
umount $input_path/sys

rm -f /mnt/dice/etc/ssh/ssh_host_*
rm -f /mnt/dice/etc/ssh/moduli

# Each individual VE should have its own pair of SSH host keys. 
# The code below will wipe out the existing SSH keys and instruct the newly-created VE to create new SSH keys on first boot.
cat << EOF > /mnt/dice/etc/rc2.d/S15ssh_gen_host_keys
#!/bin/sh
ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N ''
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -t dsa -N ''
rm /etc/rc2.d/S15ssh_gen_host_keys
EOF
chmod +x /mnt/dice/etc/rc2.d/S15ssh_gen_host_keys

cd $input_path/root/
> .bash_history; > .viminfo

cd $input_path/var/log
> aptitude; > messages; > auth.log; > kern.log; > bootstrap.log
> dpkg.log; > syslog; > daemon.log; > apt/term.log; > faillog; > lastlog; > wtmp 
rm -f /mnt/dice/var/log/*.0 /mnt/dice/var/log/*.1

echo "Whats the name for that template? (without tar.gz!)"
echo "example ubuntu-8.04.3-i386"
read input_template_name
cd $input_path &&  tar --numeric-owner -zcf ~/$input_template_name.tar.gz .
