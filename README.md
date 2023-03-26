# Twitch VOD Downloader
This Bash script uses [youtube-dl](https://github.com/ytdl-org/youtube-dl) to download VODs from Twitch channels specified in the urls.txt file. It saves the videos in the folder `/home/username/Videos/VODs/` and creates a folder for each channel. It also saves JSON metadata from the `--print-json` command of youtube-dl for each video in the folder `/home/username/Videos/metadata/` and creates a folder for each channel. The metadata is dumped into a local MongoDB database.

# Usage
## Command Line Arguments
The script supports the following command line arguments:

- `--dateStart`: Specifies the start date for downloading VODs. Format: YYYYMMDD.
- `--dateEnd`: Specifies the end date for downloading VODs. Format: YYYYMMDD.
For example, to download VODs between March 1, 2023 and March 15, 2023, you would run the following command:

``` bash
./vod_downloader.sh --dateStart 20230301 --dateEnd 20230315
```
If no command line arguments are specified, the script will download VODs from the day before the current date until the current date.

## URLs file
The URLs file is located at `urls.txt` and contains the list of Twitch channels to download VODs from. The format of each line should be:

```
https://www.twitch.tv/channel_name
```

## Dependencies
This script requires the following dependencies:

- [youtube-dl](https://github.com/ytdl-org/youtube-dl)
- [jq](https://stedolan.github.io/jq/)
- [sox](http://sox.sourceforge.net/)

## Running the script
To run the script, simply navigate to the directory where the script is located and run the following command:

``` bash
./vod_downloader.sh
```

# Notes
If a VOD has already been downloaded, it will be skipped.
If a WAV file has already been downsampled to 16kHz, it will be skipped.
The script assumes that the MongoDB server is running locally and that the database twitch-vod-downloads has already been created.
The script assumes that the user running the script has read and write access to the /home/username/Videos/ directory.

This README was generated with ChatGPT