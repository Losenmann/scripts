:global funcIptv do={
	:if ([system package find name=multicast] = "") do={:put ok1}
}
