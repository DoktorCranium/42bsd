Automatic script to setup 4.2BSD on your Linux system and experience
the magic of the early 80s UNIX/BSDs 

This is possible thanks to the SIMH project and the UNIX Heritage Society 
that provides the installers + sources for these old systems. 

The script was tested on Ubuntu 20.04 and should work as is on other 
Debian based distributions. Oher Linux distros or BSDs need some adjustement 
especialy to the additional libraries + headers needed for the SIMH build 

Script is a simple bourne shell script that does all the long and tedious 
setup of the ancient 4.2BSD as it was described in these articles 

 - http://plover.net/~agarvin/4.2bsd.html
 - https://gunkies.org/wiki/Installing_4.2_BSD_on_SIMH

Please follow the generated README.TXT closely as this is a manual part 
one has to do and is split into 4 stages 

 - install      
 - install2 
 - install3 
 - boot 

To get networking going make sure you have the required tap and bridge 
This is done via 

  apt–get install uml-utilities bridge-utils 

The networking sciprt (run this prior SIMH exution) is as follows 
Adjust according to your needs  

  #Setup tap and bridge 
  tunctl -t tap0 -u user
  ifconfig tap0 up
  brctl addbr br0
  brctl setfd br0 0
  ifconfig br0 10.0.2.2 netmask 255.255.255.0 broadcast 10.0.2.255 up
  brctl addif br0 tap0  
  ifconfig tap0 0.0.0.0
  sysctl net.ipv4.ip_forward=1
  iptables --table nat -A POSTROUTING --out-interface wlan0 -j MASQUERADE


