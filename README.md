# OpenshiftContainerPlatofrm

1. Install hostonly file (Using KVM ONLY)

```
    sudo virsh net-define hostonly.xml
    virsh net-start hostnet
    virsh net-autostart hostnet
    sudo systemctl restart libvirtd
```

2.  Log to Red Hat Portal and download (rhcos iso, openshift-client, openshift-install, pull-secret)
3.  Extract file and mv to /usr/local/bin
4.  Preparing Bastion Node [bastionNode](bastionNode.yml)
5.  Configuring Zones and masquerading (SNAT) 
6.  Configuration DNS
8.  Configuration DHCP,
9.  Configuration  APACHE 
10. Configuration HAProxy 
11. Configuration  NFS