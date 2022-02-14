/system/script/add name="scrLedControl" policy="read,write,policy,test" source={:global funcLedControl do={
:local t1 "07:00:00";
:local t2 "23:00:00";
/system/scheduler/
:if ([find name=funcLedControlOn] = "") \
    do={add name=funcLedControlOn interval=24:00:00 start-time=$t1 on-event="\$funcLedControl x=1"} \
    else={:if ([find name=funcLedControlOn interval=24:00:00 start-time=$t1 on-event="\$funcLedControl x=1"] = "") \
        do={set name=funcLedControlOn interval=24:00:00 start-time=$t1 on-event="\$funcLedControl x=1"}};
:if ([find name=funcLedControlOff] = "") \
    do={add name=funcLedControlOff interval=24:00:00 start-time=$t2 on-event="\$funcLedControl x=0"} \
    else={:if ([find name=funcLedControlOff interval=24:00:00 start-time=$t2 on-event="\$funcLedControl x=0"] = "") \
        do={set name=funcLedControlOff interval=24:00:00 start-time=$t2 on-event="\$funcLedControl x=0"}};
:if ([find name=schedStartup] = "") \
    do={add name=schedStartup start-time=startup on-event="/system/script/run scrLedControl"} \
    else={:if ([find name=schedStartup start-time=startup on-event="/system/script/run scrLedControl"] = "") \
        do={set name=schedStartup start-time=startup on-event="/system/script/run scrLedControl"}};
:if ($x = 1) do={/system/leds/settings/set all-leds-off="never"} else={/system/leds/settings/set all-leds-off="immediate"}};
:if ([:len $funcLedControl] > 0) do={$funcLedControl};
}
/system/script/run scrLedControl
