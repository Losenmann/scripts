:global funcSec{
/ip
	socks set enabled=no
	proxy set enabled=no
	service disable api,api-ssl,ftp,telnet,www-ssl
/tool
	bandwidth-server set enabled="no"
	romon set enabled="no"
	mac-server set allowed-interface-list=LAN
	mac-server mac-winbox set allowed-interface-list=LAN
/}
