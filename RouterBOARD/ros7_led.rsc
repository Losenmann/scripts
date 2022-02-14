/system/script/add name="scrLedControl" policy="read,write,policy,test" source={:global funcLedControl do={
:local t1 "07:00:00";
:local t2 "23:00:00";
:if ([/system/scheduler/find name=funcLedControlOn] = "") \
    do={/system/scheduler/add name=funcLedControlOn interval=24:00:00 start-time=$t1 on-event="\$funcLedControl x=1"} \
    else={:if ([/system/scheduler/find name=funcLedControlOn interval=24:00:00 start-time=$t1 on-event="\$funcLedControl x=1"] = "") \
        do={/system/scheduler/set name=funcLedControlOn interval=24:00:00 start-time=$t1 on-event="\$funcLedControl x=1"}};
:if ([/system/scheduler/find name=funcLedControlOff] = "") \
    do={/system/scheduler/add name=funcLedControlOff interval=24:00:00 start-time=$t2 on-event="\$funcLedControl x=0"} \
    else={:if ([/system/scheduler/find name=funcLedControlOff interval=24:00:00 start-time=$t2 on-event="\$funcLedControl x=0"] = "") \
        do={/system/scheduler/set name=funcLedControlOff interval=24:00:00 start-time=$t2 on-event="\$funcLedControl x=0"}};
:if ([/system/scheduler/find name=schedStartup] = "") \
    do={/system/scheduler/add name=schedStartup start-time=startup on-event="/system/script/run scrLedControl"} \
    else={:if ([/system/scheduler/find name=schedStartup start-time=startup on-event="/system/script/run scrLedControl"] = "") \
        do={/system/scheduler/set name=schedStartup start-time=startup on-event="/system/script/run scrLedControl"}};
:if ($x = 1) do={/system/leds/settings/set all-leds-off="never"} else={/system/leds/settings/set all-leds-off="immediate"}
};
:if ([:len $funcLedControl] > 0) do={$funcLedControl};
}
/system/script/run scrLedControl
