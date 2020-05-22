#!/usr/bin/env zsh

COUNT=6

function get_gateway_ip {
    for ((i=0; i < 5; i++)); do
        ip=$(/sbin/ip route | awk '/default via / { print $3 }');
        if [ "$ip" != "" ]; then
            echo $ip
            return
        fi
        /sbin/wpa_cli -i wlan0 reconfigure
        sleep 10
    done
}

gateway_ip=$(get_gateway_ip)

if [ "$gateway_ip" = "" ]; then
    echo "unable to get gateway IP." >&2
    exit
fi

count=$(ping -c $COUNT -q ${gateway_ip} | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
if [ "$count" = "0" ]; then
    echo "Connectivity test failed (IP: ${gateway_ip}). Let's try to reconnect to WiFi AP." >&2
else
    echo "Connectivity test passed. Packet(s) received: ${count}."
fi
