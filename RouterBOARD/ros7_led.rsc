/system/script/add source=":global funcLedControl do={
:local t1 "06:00:00";
:local t2 "23:00:00";
/system/scheduler/
:if ([find number=funcLedControlOn] = "funcLedControlOn") \
	do={set name=funcLedControlOn interval=24:00:00 start-time=$t1} \
	else={add name=funcLedControlOn interval=24:00:00 start-time=$t1 on-event="\$funcLedControl x=1"};
:if ([find number=funcLedControlOff] = "funcLedControlOff") \
	do={set name=funcLedControlOff interval=24:00:00 start-time=$t2} \
	else={add name=funcLedControlOff interval=24:00:00 start-time=$t2 on-event="\$funcLedControl x=0"};
:if ($x = 1) do={/system/leds/settings/set all-leds-off="never"} else={/system/leds/settings/set all-leds-off="immediate"}
};
:if ([:len $funcLedControl] > 0) do={$funcLedControl};"
