/system/script/add name="scrLedControl" source={:global funcLedControl do={
:local t1 "07:00:00";
:local t2 "23:00:00";
/system/scheduler/
:if ([find number=funcLedControlOn] = "funcLedControlOn") \
	do={:if ([find name=funcLedControlOn interval="24:00:00" start-time=$t1 on-event="\$funcLedControl x=1"] = "") \
		do={set name=funcLedControlOn interval="24:00:00" start-time=$t1 on-event="\$funcLedControl x=1"}} \
	else={add name=funcLedControlOn interval="24:00:00" start-time=$t1 on-event="\$funcLedControl x=1"};
:if ([find number=funcLedControlOff] = "funcLedControlOff") \
	do={:if ([find name=funcLedControlOff interval="24:00:00" start-time=$t2 on-event="\$funcLedControl x=0"] = "") \
		do={set name=funcLedControlOff interval="24:00:00" start-time=$t2 on-event="\$funcLedControl x=0"}} \
	else={add name=funcLedControlOff interval="24:00:00" start-time=$t2 on-event="\$funcLedControl x=0"};
:if ([find number=schedStartup] = "schedStartup") \
	do={:if ([find name=schedStartup start-time="startup" on-event="/system/script/run scrLedControl"] = "") \
		do={set name=schedStartup start-time="startup" on-event="/system/script/run scrLedControl"}} \
	else={add name=schedStartup start-time="startup" on-event="/system/script/run scrLedControl"};
:if ($x = 1) do={/system/leds/settings/set all-leds-off="never"} else={/system/leds/settings/set all-leds-off="immediate"}
};
:if ([:len $funcLedControl] > 0) do={$funcLedControl};} policy="read,write,policy,test"
/system/script/run scrLedControl
