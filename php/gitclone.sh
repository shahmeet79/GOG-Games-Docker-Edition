#!/bin/sh

# Exit if already cloned the repository
CHECK_FOR_FILES=$(ls /usr/share/nginx/html | wc -l)
if [ "$CHECK_FOR_FILES" -gt "0" ]; then
	exit
fi

while true; do

# Clone GOG Games GitHab repository using Tor proxy
TOR_STAT=$(curl --socks5 tor:9050 --socks5-hostname tor:9050 -s https://check.torproject.org/ | cat | grep -m 1 Congratulations | xargs)
if [ "$TOR_STAT" = "Congratulations. This browser is configured to use Tor." ]; then
	git config --global http.proxy socks5h://tor:9050
	git clone "https://github.com/MachineGunnur/GOG-Games.git" /usr/share/nginx/html
	cd "/usr/share/nginx/html/"
	composer install
	exit
else
	sleep 1s
	continue
fi
done