#! /bin/bash
#@author Vincent 'challenger1304' Neubauer

###CONFIGURATION
urlPref="http://www.nick.de/shows/"
dlFolder="$HOME/Downloads"
regex="<a href='\K(http:\/\/www\.nick\.de\/shows\/.{1,}\/videos\/.{1,})(?='>)"

mkdir -p ~/.darlor/nick-dl
cp ${0} ~/.darlor/nick-dl/ 2>/dev/null
cd ~/.darlor/nick-dl

case "${1}" in
"-a" | "--all")
	curl -s "$urlPref${2}" | grep -oP "$regex" | while read -r line ; do
		${0} $line
		echo "---------------"
	done
	echo ===SERIES=COMPLETED===
	;;

"-u" | "--urllist")
	#downloads all series given in a file
	#each link to a series in a separate line (without "http://www.nick.de/shows/")
	while read url; do
		echo "===NEXT=SERIES==="
		${0} --all "$url"
	done <${2}
	;;

*)
	#downloads video from url in first parameter
	uri=`echo ${1} | grep -oP "$urlPref\K.{1,}"` #truncate optional url-prefix
	thisSeason=`curl -s "$urlPref$uri" | grep -m 1 -oP 'Staffel \K\d{1,}(?= - Folge \d{1,})'`
	thisSeason=$(printf "%02d" $thisSeason)
	thisEpisode=`curl -s "$urlPref$uri" | grep -m 1 -oP 'Staffel \d{1,} - Folge \K\d{1,}'`
	thisEpisode=$(printf "%02d" $thisEpisode)
	thisSeries=`curl -s "$urlPref$uri" | grep -m 1 -oP "<p class='title'>\K.{1,}(?=</p>)"`
	thisTitle="$thisSeries - S${thisSeason}E${thisEpisode}.flv"
	echo "Title: $thisTitle"
	echo "Series: $thisSeries"
	echo "Episode: S${thisSeason}E${thisEpisode}"
	echo "URL: $urlPref$uri"

	youtube-dl --all-subs --download-archive ./dl.list -w --output "$thisTitle" "$urlPref$uri"

	mkdir -p "$dlFolder/$thisSeries/Season $thisSeason"
	mv "$thisTitle" "$dlFolder/$thisSeries/Season $thisSeason/$thisTitle"
	;;
esac
