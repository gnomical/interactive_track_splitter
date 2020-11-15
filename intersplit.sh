#!/bin/bash
seek=0
trackFile=

while [ ! $# -eq 0 ]
do
	case "$1" in
		-i)
			filePath=$2
			;;
		--seek | -s)
			seek=$2
			;;
    --tracklist | -t)
      if [[ $2 == */* ]]; then
        trackFile=$2
      else
        trackFile="./${2}"
      fi
			;;
	esac
	shift # past argument flag
  shift # past argument value
done

# manage tracklist, convert to a map array
# key is track number
# value is array of title, hh:mm:ss
trackTitle=()
trackPos=()
track=0
if [[ $trackFile != "" ]]; then
  while IFS= read -r line
  do
    trackTitle[$track]=${line%" "*} # everything before last space
    trackPos[$track]=${line##*" "} # everything after last space
    ((track++))
  done < "$trackFile"
fi

# https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
fileExt=${filePath#*.}
# remove ext from filePath
fileName=${filePath%%.*}
# separate path from file
if [[ $fileName == */* ]]; then
  dir=${fileName%%/*}
  fileName=${fileName#*/}
  outPath="${dir}/${fileName}"
else
  outPath="./${fileName}"
fi

#create a directory with the same name as the file we are splitting
echo "mkdir ${outPath}"
mkdir "${outPath}"

splitting=true
segment=0
nextSeek=0
success=y
count=0

while [ "$splitting" = true ]
do
  if [ "$success" = y ]; then
    ((count++))
    ((seek+=segment))
    echo " "
    echo "--- Track ${count} (ss:${seek}) ---"
    echo "(raw seconds or mm:ss format | 0 for all remaining)"
    if [[ $trackFile != "" ]]; then
      read -p "How long is the next segment? (default: ${trackPos[count-1]}) " segment
      if [[ $segment == "" ]]; then
        segment=${trackPos[count-1]}
      fi
    else
      read -p "How long is the next segment? " segment
    fi
    if [[ $segment == *:*:* ]]; then
      hours=${segment%%:*} # content left of first :
      hours=${hours#0}  # remove leading 0
      segment=${segment#*:} # content right of :
    fi
    if [[ $segment == *:* ]]; then
      minutes=${segment%:*} # content left of :
      minutes=${minutes#0}  # remove leading 0
      seconds=${segment#*:} # content right of :
      seconds=${seconds#0}  # remove leading 0
      segment=$((minutes*60+seconds))
    fi
  else
    read -p "How much should we adjust it? " adjustment
    ((segment+=adjustment))
    rm -f "${outPath}/${fileName}_${count}.${fileExt}"
  fi
  if [ "$segment" = 0 ]; then
    splitting=false
    mv "${outPath}/${fileName}_remaining.${fileExt}" "${outPath}/${fileName}_${count}.${fileExt}"
  else
    nextSeek=$((seek + segment))

    # echo "${outPath}/${fileName}_${count}.${fileExt}"
    if [[ $trackFile != "" ]]; then
      ffmpeg -loglevel quiet -ss $seek -i "$filePath" -t $segment -c copy -metadata track="$count" -metadata title="${trackTitle[count-1]}" "${outPath}/${fileName}_${count}.${fileExt}"
    else
      ffmpeg -loglevel quiet -ss $seek -i "$filePath" -t $segment -c copy -metadata track="$count" "${outPath}/${fileName}_${count}.${fileExt}"
    fi

    rm -f "${outPath}/${fileName}_remaining.${fileExt}"
    ffmpeg -loglevel quiet -ss $nextSeek -i "$filePath" -c copy "${outPath}/${fileName}_remaining.${fileExt}"

    read -p "Was that the right split point? [y/n]: " success
  fi
done
