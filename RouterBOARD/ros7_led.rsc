############### COVER ################
/system/script/add name="scrLedControl" policy="read,write,policy,test" source={
################ BODY ################
# Control via "x=true/false" or call a function without passing an argument
# The "mainStartup" scheduler is used to automatically load the script
############## FUNCTION ##############
:global funcLedControl do={
:local x
:if ([/system/leds/settings/get all-leds-off] = "never") \
    do={/system/leds/settings/set all-leds-off="immediate"} \
    else={/system/leds/settings/set all-leds-off="never"};
:if (:len $x != 0 and $x = true) \
    do={/system/leds/settings/set all-leds-off="never"} \
    else={:if (:len $x != 0 and $x = false) \
        do={/system/leds/settings/set all-leds-off="immediate"}};}
############# /FUNCTION ##############
:if ([/system/scheduler/find name="mainStartup"] = "") \
    do={/system/scheduler/add name="mainStartup" start-time="startup"};
:if ([/system/scheduler/find name="mainStartup" on-event~".scrledcontrol."] = "") \
    do={/system/scheduler/set mainStartup on-event=([/system/scheduler/get mainStartup value-name="on-event"] . "/system/script/run scrLedControl\n")};
############### /BODY ################
};
/system/script/run scrLedControl
############### /COVER ###############
