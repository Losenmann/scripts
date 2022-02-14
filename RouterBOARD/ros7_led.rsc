################ COVER
/system/script/add name="scrLedControl" policy="read,write,policy,test" source={
################ BODY
:global funcLedControl do={
:local x
:if ([/system/leds/settings/get all-leds-off] = "never") \
    do={/system/leds/settings/set all-leds-off="immediate"} \
    else={/system/leds/settings/set all-leds-off="never"};
:if (:len $x != 0 and $x = true) \
    do={/system/leds/settings/set all-leds-off="never"} \
    else={:if (:len $x != 0 and $x = false) \
        do={/system/leds/settings/set all-leds-off="immediate"}};}
################ BODY
/system/script/run scrLedControl;
}
################ COVER
