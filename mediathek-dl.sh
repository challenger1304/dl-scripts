#! /bin/bash
#@author Vincent 'challenger1304' Neubauer
# usage: mediathek-dl.sh SERIES-NAME DOCUMENT_ID
###CONFIGURATION
DLFOLDER="$HOME/Downloads"
CONFIG="$HOME/.config/darlor/mediathek-dl"
mkdir -p ~/.config/darlor
EPISODES=$(curl --silent "http://mediathek.daserste.de/${1}/Sendung?documentId=${2}&rss=true" \
  | grep -oP '<link>.*?\d{1,}/Video.*?(?=</link>)' | sed -e 's/<link>//' -e 's/bcastId=1555306&amp;//')
for EPISODE in ${EPISODES[@]}
do
  mkdir -p "$DLFOLDER/${1}"
  cd "$DLFOLDER/${1}"
  youtube-dl --all-subs --download-archive "$CONFIG" -w "$EPISODE"
done
