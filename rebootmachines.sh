#!/bin/bash

for machines  in 172.19.195.{53..58}
do
   printf "Rebooting $ ... \n"
   ssh root@${machines} reboot
   sleep 2
done