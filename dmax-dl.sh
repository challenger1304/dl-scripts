#! /bin/bash
#@author Vincent 'challenger1304' Neubauer

###CONFIGURATION
URLPREF="https://www.dmax.de"
DLFOLDER="$HOME/Downloads"

mkdir -p ~/.config/darlor/dmax-dl
cp ${0} ~/.config/darlor/dmax-dl/ 2>/dev/null
cd ~/.config/darlor/dmax-dl

case "${1}" in
"-a" | "--all")
	#follows next-video links on the website
	${0} ${2} #call script without extra parameter
	echo "===NEXT=EPISODE==="
	NEXT_URL=`curl -s "$URLPREF${2}" | grep -m 1 -oP '<h3 class="vertical-list-item__title"><a href="\K(.*?)"' | head -1 | cut -d '"' -f1`

	if  [ $NEXT_URL  ] ; then
		${0} --all "$NEXT_URL" #go to next url
	else
		echo "===END=OF=SERIES=="
	fi
	;;

"-u" | "--urllist")
	#downloads all series given in a file
	#each link to first episode of series in separate line (without "https://www.dmax.de")
	while read url; do
		${0} --all "$url"
		echo "===NEXT=SERIES==="
	done <${2}
	;;

*)
	#downloads video from url in first parameter
	THIS_TITLE=`curl -s "$URLPREF${1}" | grep -m 1 -oP '<meta property="og:title" content="\K.*?"' | head -1 | cut -d '"' -f1`
	echo "Title: $THIS_TITLE"
	echo "URL: $URLPREF${1}"
	THIS_TITLE="${THIS_TITLE/.F/E}"
	THIS_TITLE="${THIS_TITLE/:/ -}"	# removes last emptyspace
	THIS_TITLE="${THIS_TITLE/&#x27;/}" # removes "'"-chars

	#TODO split string on " - S"
	THIS_SERIES=`echo ${THIS_TITLE} | cut -d '-' -f1`
	THIS_SERIES=${THIS_SERIES::-1}

	THIS_SEASON=`echo ${THIS_TITLE} | grep -oP "S\d\dE"| cut -d 'S' -f2 | cut -d 'E' -f1 `
	THIS_SEASON="Season $THIS_SEASON"

	youtube-dl --all-subs --download-archive ./dl.list -w --output "$THIS_TITLE" "$URLPREF${1}"

	mkdir -p "$DLFOLDER/$THIS_SERIES/$THIS_SEASON"
	mv "$THIS_TITLE.mp4" "$DLFOLDER/$THIS_SERIES/$THIS_SEASON/$THIS_TITLE.mp4"
	;;
esac
