#!/bin/bash

# This script is based on the GitHub Repo by dmn001: https://github.com/dmn001/youtube_channel_archiver
# It has been modified to suit my use case and does not require a config file.

# Define the usage message
usage() {
    # This function prints the usage message and exits the script.
    echo "Usage: $0 <youtube_url> [-f <format>] [-s] [-r] [-i]"
    echo "Options:"
    echo "  <youtube_url>       YouTube URL (mandatory)"
    echo "  -f, --format        Output format: 'mkv' or 'mp4' (optional). Please note that mp4 requires re-encoding for > 1080p videos."
    echo "  -s, --no-subtitles  Disable subtitles (optional)"
    echo "  -r, --recode        Recode video to H.264 (optional, only applicable for mp4 format). Requires large amount of CPU time (ffmpeg and GPU acceleration is weird)"
    echo "  -i, --ignore-archive Ignore whether the video has already been archived or not"
    exit 1
}

# Initialize option variables
recode=false
ignore_archive=false

# Parse the command line options
while [ "$1" != "" ]; do
    # This loop iterates over the command line arguments and sets the corresponding option variables.
    case $1 in
        -f | --format )       shift
                                format=$1
                                if [ "$format" != "mkv" ] && [ "$format" != "mp4" ]; then
                                    echo "Invalid format. Please use 'mkv' or 'mp4'."
                                    usage
                                fi
                                ;;
        -s | --no-subtitles ) subtitles=false
                                ;;
        -r | --recode )       recode=true
                                ;;
        -i | --ignore-archive ) ignore_archive=true
                                ;;
        * )                   youtube_url=$1
                                ;;
    esac
    shift
done

# Check for mandatory option
if [ -z "$youtube_url" ]; then
    usage
fi

# Print a message indicating the start of the download
echo "Downloading YouTube video from $youtube_url..."

# Define common options for yt-dlp
# These options include the output format, thumbnail conversion, and the output file name format
common_options="-i -o \"%(uploader)s (%(uploader_id)s)/%(upload_date)s - %(title)s - (%(duration)ss) [%(resolution)s] [%(id)s].%(ext)s\" --write-thumbnail --convert-thumbnails jpg"

# If the ignore_archive option is not set, add the --download-archive option to the common options
# This option makes yt-dlp check the archive file to avoid downloading videos that have already been downloaded
if [ "$ignore_archive" = false ]; then
    common_options="$common_options --download-archive yt-dlp-archive.txt"
fi

# If the output format is MKV, download the video in MKV format
# The --merge-output-format option is used to specify the output format
if [ "$format" = "mkv" ]; then
    echo "Using MKV format..."
    eval "yt-dlp --merge-output-format mkv $common_options \"$youtube_url\""
fi

# If the output format is MP4, download the video in MP4 format
# If the recode option is set, recode the video to H.264 using the --recode-video and --postprocessor-args options
if [ "$format" = "mp4" ]; then
    echo "Using to MP4 format..."
    if [ "$recode" = true ]; then
        echo "Re-encoding..."
        eval "yt-dlp --merge-output-format mp4 --recode-video mp4 --postprocessor-args \"-vcodec h264\" $common_options \"$youtube_url\""
    else
        eval "yt-dlp --merge-output-format mp4 $common_options \"$youtube_url\""
    fi
fi