:global funcIptv do={
	:local varTest value=[system package find name=multicast];
	:if ($varTest = "") do={:put ok};
	:if ([system package find name=multicast] = "") do={:put ok1}
}
