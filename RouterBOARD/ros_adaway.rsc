:global funcAdaway do={
:local p1
:local p2
:local data
:local result 
:local uri1 "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=null;showintro=0&mimetype=plaintext"
:local uri2 "https://adaway.org/hosts.txt"
    
    :set result ([/tool/fetch "$uri1" as-value output=user]->"data");
    :set p1 "0"; :set data "";
    :do {[:set data [:pick $result $p1 [:find $result "\n" $p1]]];
            :set p1 ([:find $result "\n" $p1]+1);
            :local count ($count+1);
            /ip dns static add address="127.0.0.1" comment="Adaway" name=$data;
            }
        while=([:len $data] > 0); :put "$count rows of advertising domains processed";
    
    :set result ([/tool/fetch "$uri2" as-value output=user]->"data");
    :set p1 "0"; :set p2 "0"; :set data "";
    :do {:set data [:pick [:pick $result [:find $result "127.0.0.1" $p1] [:find $result "\n" $p2]] 10 256];
            :set p1 $p2;
            :set p2 ([:find $result "127.0.0.1" $p1]);
            :local count ($count+1);
            /ip dns static add address="127.0.0.1" comment="Adaway" name=$data;
            }
        while=([:len $data] > 0); :put "$count rows of advertising domains processed";
}
