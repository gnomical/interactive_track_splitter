#!/bin/bash
seek=0

while [ ! $# -eq 0 ]
do
	case "$1" in
		-i)
			filePath=$1
			;;
		--seek | -s)
			seek=$1
			;;
	esac
	shift
done


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
    read -p "How many seconds in the next segment? " segment
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
    ffmpeg -loglevel quiet -ss $seek -i "$filePath" -t $segment -c copy "${outPath}/${fileName}_${count}.${fileExt}"

    rm -f "${outPath}/${fileName}_remaining.${fileExt}"
    ffmpeg -loglevel quiet -ss $nextSeek -i "$filePath" -c copy "${outPath}/${fileName}_remaining.${fileExt}"

    read -p "Was that the right split point? [y/n]: " success
  fi
done
