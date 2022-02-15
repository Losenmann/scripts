############### COVER ################
/system/script/add name="scrLedControl" policy="read,write,policy,test" source={\r
################ BODY ################
# The cover is needed to import the script
# Control via "x=true/false" or call a function without passing an argument
# The "mainStartup" scheduler is used to automatically load the script
# The time is applied after the script is run and if there are no tasks
:local t1 "06:00:00"
:local t2 "23:00:00"
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
# Create a function autorun task
:if ([/system/scheduler/find name="mainStartup"] = "") \
    do={/system/scheduler/add name="mainStartup" start-time="startup" policy="read,write,policy,test"};
:if ([/system/scheduler/find name="mainStartup" on-event~".scrledcontrol."] = "") \
    do={/system/scheduler/set mainStartup on-event=([/system/scheduler/get mainStartup value-name="on-event"] . "/system/script/run scrLedControl\n")};
# Creating task to enable/disable leds
:if ([/system/scheduler/find name="LedControlOn"] = "") \
    do={/system/scheduler/add name="LedControlOn" start-time=$t1 policy="read,write,policy,test" interval="1d" on-event="\$funcLedControl x=true"};
:if ([/system/scheduler/find name="LedControlOff"] = "") \
    do={/system/scheduler/add name="LedControlOff" start-time=$t2 policy="read,write,policy,test" interval="1d" on-event="\$funcLedControl x=false";};
############### /BODY ################
};
/system/script/run scrLedControl
############### /COVER ###############
