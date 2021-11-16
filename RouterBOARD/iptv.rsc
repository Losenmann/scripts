:global funcIptv do={
	:local varTest value=[system package find name=multicast];
	:if ($varTest = "") do={:put ok}
}
