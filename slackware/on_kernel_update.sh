#!/bin/bash

KERNEL=$(ls /var/lib/pkgtools/packages | grep -i kernel-generic | grep -oP '\d+\.\d+\.\d+')


wait_to_continue(){
  echo ""
  echo "-------------------------------------------------------------------------------"
  echo "------ STATUS:"
  echo "------     $1"
  echo "------ Press any key to continue"
  echo "-------------------------------------------------------------------------------"
  echo ""
  read -n 1 -s -r
}


# Generate initrd
echo "Generating initrd for kernel $KERNEL"
sudo $(sudo /usr/share/mkinitrd/mkinitrd_command_generator.sh -k $KERNEL | sed '/^#/d')
wait_to_continue "Generated initrd"

# Reinstall grub if it was upgraded
GRUB_EFI_VERSION=$(cat /boot/efi/EFI/Slackware/grub/version.txt 2>/dev/null || echo "grub")
GRUB_VERSION=$(ls /var/lib/pkgtools/packages | grep ^grub)
if [ $GRUB_VERSION != $GRUB_EFI_VERSION ]; then
  # Install grub
  sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck --debug
  # Save the version used to generate the efi file
  echo -n $GRUB_VERSION | sudo tee /boot/efi/EFI/Slackware/grub/version.txt > /dev/null
  # Organize
  sudo mv /boot/efi/EFI/grub/grubx64.efi /boot/efi/EFI/Slackware/grub/grubx64.efi
  sudo rm -rf /boot/efi/EFI/grub
  # Create a new boot entry for grub
  sudo efibootmgr --create --disk=/dev/nvme0n1 --part=1 --label="Slackware grub" --loader='EFI\Slackware\grub\grubx64.efi'
  wait_to_continue "Reinstalled grub. Make sure to update the boot order!!! Ex: efibootmgr --bootorder 000A,0005,0000,0004,0003,0001"
fi


# Update grub config
echo "Updating grub configuration"
sudo grub-mkconfig -o /boot/grub/grub.cfg
wait_to_continue "Updated grub configuration"


# Update elilo and elilo.conf
sudo cp /boot/vmlinuz-generic /boot/efi/EFI/Slackware/elilo/
# OLD: before kernel-huge package was removed
# sudo cp /boot/vmlinuz-$KERNEL-generic /boot/efi/EFI/Slackware/elilo/
# sudo cp /boot/vmlinuz-$KERNEL-huge /boot/efi/EFI/Slackware/elilo/
# OLD: initrd kernel naming
# sudo cp /boot/vmlinuz-generic-$KERNEL /boot/efi/EFI/Slackware/elilo/
# sudo cp /boot/vmlinuz-huge-$KERNEL /boot/efi/EFI/Slackware/elilo/
sudo cp /boot/initrd.gz /boot/efi/EFI/Slackware/elilo/
# OLD: No longer needed with the current initrd naming
# sed -i "s/image=vmlinuz-generic-.*/image=vmlinuz-generic-$KERNEL/" /boot/efi/EFI/Slackware/elilo/elilo.conf
# sed -i "s/image=vmlinuz-huge-.*/image=vmlinuz-huge-$KERNEL/" /boot/efi/EFI/Slackware/elilo/elilo.conf
wait_to_continue "Updated elilo configuration"


# Update bbswitch
# echo "Updating bbswitch"
# cd /home/niko/Packages/bumblebee/bumblebee/bbswitch
# sudo KERNEL=$KERNEL ./bbswitch.SlackBuild
# sudo upgradepkg --reinstall --install-new /tmp/bbswitch-*$KERNEL-*.txz
# wait_to_continue "Updated bbswitch"


echo "Make sure to updat nvidia-kernel and nvidia-driver manually"
# echo "Updating nvidia-kernel"
# cd /home/niko/Packages/bumblebee/bumblebee/nvidia-kernel
# sudo KERNEL=$KERNEL ./nvidia-kernel.SlackBuild
# sudo upgradepkg --reinstall --install-new /tmp/nvidia-kernel-*$KERNEL-*.txz
# wait_to_continue "Updated nvidia-kernel"
