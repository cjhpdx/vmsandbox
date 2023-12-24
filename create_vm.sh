#!/bin/bash

# VM Configuration
VM_NAME="UbuntuVM"
ISO_PATH="/home/cjharris/Downloads/ubuntu-22.04.3-live-server-amd64.iso"
HDD_SIZE=20000 # 20 GB
CPU_COUNT=2
RAM_SIZE=4096 # 4 GB

# Create VM
VBoxManage createvm --name $VM_NAME --ostype "Ubuntu_64" --register

# Set memory and CPUs
VBoxManage modifyvm $VM_NAME --memory $RAM_SIZE --cpus $CPU_COUNT

# Create a virtual hard disk
VBoxManage createhd --filename ~/VirtualBox\ VMs/$VM_NAME/$VM_NAME.vdi --size $HDD_SIZE

# Attach the hard disk and ISO
VBoxManage storagectl $VM_NAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $VM_NAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ~/VirtualBox\ VMs/$VM_NAME/$VM_NAME.vdi
VBoxManage storagectl $VM_NAME --name "IDE Controller" --add ide
VBoxManage storageattach $VM_NAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $ISO_PATH

# Setup network for SSH
VBoxManage modifyvm $VM_NAME --nic1 nat
VBoxManage modifyvm $VM_NAME --natpf1 "guestssh,tcp,,2222,,22"

# Generate SSH key (if it doesn't exist)
SSH_KEY="$HOME/.ssh/id_rsa"
if [ ! -f "$SSH_KEY" ]; then
    ssh-keygen -t rsa -b 2048 -f $SSH_KEY -N ""
    echo "SSH key generated at $SSH_KEY"
else
    echo "SSH key already exists at $SSH_KEY"
fi

# Start the VM
VBoxManage startvm $VM_NAME

echo "VM $VM_NAME created and started. You can SSH into it after installation using 'ssh -p 2222 user@localhost'"

