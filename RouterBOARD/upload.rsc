:global funcUpload do={
# Variables: led
    :if (led = "true") do={
        :local result [/tool fetch https://raw.githubusercontent.com/Losenmann/scripts/master/RouterBOARD/ros7_led.rsc as-value output=user];
        :execute [($result->"data")];
    }
}
