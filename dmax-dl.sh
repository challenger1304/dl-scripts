#! /bin/bash
mkdir -p ~/.darlor/dmax-dl
cp ${0} ~/.darlor/dmax-dl/ 2>/dev/null
cd ~/.darlor/dmax-dl

for episode in "$@"
do
        if [ "$episode" != "--all" ] && [ "$episode" != "-a" ] ; then
                echo $episode > episode.url
                wget -q $episode -O episode.html

                DLFOLDER="$HOME/Documents"

                NEXT_URL=`grep -m 1 -oP '<h3 class="vertical-list-item__title"><a href="\K(.*?)"' episode.html | head -1 | cut -d '"' -f1`

                THIS_TITLE=`grep -m 1 -oP '<meta property="og:title" content="\K.*?"' episode.html | head -1 | cut -d '"' -f1`
                THIS_TITLE="${THIS_TITLE/.F/E}"
                THIS_TITLE="${THIS_TITLE/:/ -}"    # removes last emptyspace
                THIS_TITLE="${THIS_TITLE/&#x27;/}" # removes "'"-chars

                #TODO split string on " - S"
                THIS_SERIES=`echo ${THIS_TITLE} | cut -d '-' -f1`
                THIS_SERIES=${THIS_SERIES::-1}

                THIS_SEASON=`echo ${THIS_TITLE} | grep -oP "S\d\dE"| cut -d 'S' -f2 | cut -d 'E' -f1 `
                THIS_SEASON="Season $THIS_SEASON"

                youtube-dl --all-subs --download-archive ./dl.list -w --output "$THIS_TITLE" -a ./episode.url
                rm episode.url
                rm episode.html

                mkdir -p "$DLFOLDER/$THIS_SERIES/$THIS_SEASON"
                echo "$DLFOLDER/$THIS_SERIES/$THIS_SEASON/$THIS_TITLE.mp4"
                mv "$THIS_TITLE.mp4" "$DLFOLDER/$THIS_SERIES/$THIS_SEASON/$THIS_TITLE.mp4"

                if [ "${1}" = "--all" ] || [ "${1}" = "-a" ] ; then
                        if  [ $NEXT_URL  ] ; then
                                ${0} --all "https://www.dmax.de$NEXT_URL"
                        else
                                echo "Downloads finished"
                        fi
                fi
        fi
done
