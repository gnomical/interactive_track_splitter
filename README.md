# interactive_track_splitter
CLI for splitting a media file using ffmpeg but only needing to enter the next segment length. This is mostly useful while splitting a large file whose track positions are either slightly out of position or completely unknown. I use this to split downloaded audio books into files for each chapter in the book when the tagged chapters are not accurate. The script will save the segment you just specified and then a track titled `_remaining`. I usually play the `_remaining` track to identify if the last segment length was correct. The program then allows you to make smalll adjustments to the previous split by entering an integer.

## Requirements
ffmpeg command line utility
https://trac.ffmpeg.org/wiki/CompilationGuide/macOS

## How to use
launch the script called intersplit and pass it the path of the file you want to split like so
```shell
    ./intersplit.sh ~/My\ Folder/My\ media\ file.m4a
```
