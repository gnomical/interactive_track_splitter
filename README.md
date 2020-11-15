# interactive_track_splitter
CLI for splitting a media file using ffmpeg but only needing to enter the next segment length. 

This is mostly useful while splitting a large file whose track positions are either slightly out of position or completely unknown. I use this to split downloaded audio books into files for each chapter in the book when the tagged chapters are not accurate. The script will save the segment you just specified and then a track titled `_remaining`. I usually play the `_remaining` track to identify if the last segment length was correct. The program then allows you to make small adjustments to the previous split by entering an integer.

## Requirements
ffmpeg command line utility

https://trac.ffmpeg.org/wiki/CompilationGuide/macOS

## How to use
launch the script called intersplit and pass it the path of the file you want to split like so
```shell
    ./intersplit.sh -i ~/My\ Folder/My\ media\ file.m4a
```

## Features
- Tag output files with track number
- Tag output files with track title
- adjust split position as many times as needed
- tested with .m4a files

## Options
- `-i`
    - required
    - The file path for the media you wish to split
- `-s | --seek`
    - default: 0
    - start position in seconds, all content before this position will be ignored
- `-t | --tracklist`
    - optional
    - provide a text file with track titles followed by track length
    ```
        Opening Credits 00:07:23
        Part One 00:26:08
        Part Two 00:31:07
        Part Three 01:04:02
        Part Four 00:25:17
    ```
    - This will allow the script to tag each track title as well as auto populate the segment values