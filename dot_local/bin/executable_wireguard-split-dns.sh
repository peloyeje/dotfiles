#!/bin/sh
set -eu

resolver=/etc/resolver/lan.peloye.je
nameserver='nameserver 10.100.100.1'

is_tunnel_up() {
    /usr/sbin/scutil --nc status 'home.peloye.je LAN' 2>/dev/null |
        /usr/bin/grep -qx Connected
}

if is_tunnel_up; then
    /bin/mkdir -p /etc/resolver
    if [ ! -f "$resolver" ] || [ "$(/bin/cat "$resolver")" != "$nameserver" ]; then
        /usr/bin/printf '%s\n' "$nameserver" > "$resolver"
        /usr/bin/killall -HUP mDNSResponder 2>/dev/null || true
    fi
elif [ -e "$resolver" ]; then
    /bin/rm -f "$resolver"
    /usr/bin/killall -HUP mDNSResponder 2>/dev/null || true
fi
