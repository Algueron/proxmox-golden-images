#!/bin/bash

# Remove previous occurence if it exists
sudo qm destroy 9000

# Download the latest Cloud Init Ubuntu image
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

# Change the extension of the image file to qcow2
mv focal-server-cloudimg-amd64.img focal-server-cloudimg-amd64.qcow2

# Define your virtual machine which you'd like to use as a template
sudo qm create 9000 --name "ubuntu-2004-cloudinit-template" --memory 2048 --net0 virtio,bridge=vmbr0 -cores 1 -sockets 1 -cpu cputype=kvm64 -description "Ubuntu 20.04 cloud image" -kvm 1 -numa 1

# Import the disk image in the local Proxmox storage for disk images
sudo qm importdisk 9000 focal-server-cloudimg-amd64.qcow2 pvecontent

# Configure your virtual machine to use the uploaded image
sudo qm set 9000 --scsihw virtio-scsi-pci --scsi0 pvecontent:vm-9000-disk-0

# Add the Cloud-init image as CD-Rom to your virtual machine
sudo qm set 9000 --ide2 pvecontent:cloudinit

# Restrict the virtual machine to boot from the Cloud-init image only
sudo qm set 9000 --boot c --bootdisk scsi0

# Attach a serial console to the virtual machine
sudo qm set 9000 --serial0 socket --vga serial0

# Declare the virtual machine as a template
sudo qm template 9000

# Remove the Ubuntu image
rm focal-server-cloudimg-amd64.qcow2
