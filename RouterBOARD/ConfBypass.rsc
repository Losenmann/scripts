############### COVER ################
/system script add name="scrConfBypass" policy="read,write,policy,test" source={
################ BODY ################
# The function configures the device to redirect traffic to specific hosts via an alternate route.
# Supported inputs:
# help or "?" - Reference Informations
# gwbypass="..." Alternate Gateway
############## FUNCTION ##############
:global funcConfBypass do={
    :if ($1 = "help") do={
        :put "Command list:";
        :put "gwbypass=\"...\" Alternate Gateway";
        :error "";
        };
    :if ([:len $gwbypass] > 0) do={
        :put "Gateway for bypass list: $gwbypass";
        } else={
        :error "Not specified gateway for bypass list! gwbypass=\"...\"";
        };
    /routing table
    add name="rtab-bypass" fib;
    ..rule
    add action="lookup-only-in-table" disabled="no" routing-mark="rtab-bypass" table="rtab-bypass";
    /ip route
    add dst-address="0.0.0.0/0" gateway=$gwbypass distance="50" routing-table="rtab-bypass";
    /ip firewall mangle
    add action="mark-connection" chain="prerouting" connection-state="established,related,new" \
        dst-address-list="bypass" new-connection-mark="conn-bypass" passthrough="yes";
    add action="mark-routing" chain="prerouting" connection-mark="conn-bypass" dst-address-list="bypass" \
        new-routing-mark="rtab-bypass" passthrough="yes";
    ..filter
    print;
    set numbers=[find chain="forward" action="fasttrack-connection"] connection-mark=!"conn-bypass";
    :put "Device configured successfully to redirect traffic from the bypass list! :)";
    :put "Add hosts to \"bypass\" list in /ip/firewall/address-list menu";
};
############## FUNCTION ##############
################ BODY ################
};
/system script run scrConfBypass
############### COVER ################
