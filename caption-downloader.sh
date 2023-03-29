#!/bin/bash

url_file_path="urls_youtube.txt"
#Channel name and url are separated by a comma
while read -r i;
do
    echo "$i"
    channel_name=$(echo "$i" | cut -d',' -f1)
    url=$(echo "$i" | cut -d',' -f2)
    destination_folder="$HOME/Videos/captions/$channel_name"
    #Create folder if it doesn't exist
    if [ ! -d "$destination_folder" ]; then
        mkdir -p "$destination_folder"
    fi
    echo "Downloading captions from $channel_name"
    youtube-dl --verbose --skip-download --write-auto-sub --sub-lang en --sub-format srt --convert-subs srt --output "$destination_folder/%(title)s.srt" "$url"
done < "$url_file_path"