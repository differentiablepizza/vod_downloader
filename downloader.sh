#!/bin/bash

# Uses youtube-dl to download VODs from channels given in the file urls.txt.
# It saves the videos in the folder /home/username/Videos/ and creates a folder for each channel.
# It also saves JSON metadata from the `--print-json` command of youtube-dl for each video in the folder /home/username/Videos/metadata/ and creates a folder for each channel.

# Parse command line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --dateStart)
    StartDate="$2"
    shift 2
    ;;
    --dateEnd)
    EndDate="$2"
    shift 2
    ;;
    *)    # unknown option
    shift
    ;;
esac
done

# Get current date and time and subtract one day
DateYesterday=$(date -d "yesterday 13:00" '+%Y%m%d')
DateNow=$(date -d "now 13:00" '+%Y%m%d')

# Set default dates if they haven't been overwritten
StartDate=${StartDate:-$DateYesterday}
EndDate=${EndDate:-$DateNow}

echo "Start date: $StartDate"
echo "End date: $EndDate"

# Loop through each line in the file
url_file_path="urls.txt"
while read -r i;
do
    # Get the channel name from the url. Example: https://www.twitch.tv/filian/<streamer_name>?filter=all
    ChannelName=$(echo $i | cut -d'/' -f4)
    filepath="$HOME/Videos/VODs/$ChannelName"
    # Create a folder for the channel if it doesn't exist
    mkdir -p $filepath
    # Create a folder for the metadata if it doesn't exist
    mkdir -p $HOME/Videos/metadata/$ChannelName

    echo "Getting data from $ChannelName"
    # Get the video ids and metadata
    data=$(youtube-dl --skip-download --dateafter $StartDate --datebefore $EndDate --print-json $i)
    video_ids=$(echo $data | jq -r '.timestamp')

    # Download videos and metadata
    for video_id in $video_ids; do
        # Check if video is already downloaded. If not, download it.
        if [ ! -f "$filepath/$video_id.wav" ]; then
            echo "Downloading $video_id"
            youtube-dl -o "$filepath/%(timestamp)s.%(ext)s" -x --audio-format wav -v --dateafter $StartDate --datebefore $EndDate $i
        else
            echo "Skipping $video_id"
        fi

        # Check if WAV is already 16kHz. If not, downsample it.
        if [ $(soxi -r "$filepath/$video_id.wav") -eq 16000 ]; then
            echo "Skipping downsampling for $video_id"
        else
            echo "Downsampling to 16kHz for $video_id"
            sox "$filepath/$video_id.wav" -r 16000 -c 1 "$filepath/$video_id"_16kHz.wav && mv "$filepath/$video_id"_16kHz.wav "$filepath/$video_id.wav"
        fi
    done

    echo "Saving metadata"
    # Dump json into a local mongoDB database
    echo $data | jq -c '.[]' | mongoimport --db twitch-vod-downloads --collection $ChannelName --jsonArray

    echo "Done"
done < "$url_file_path"
