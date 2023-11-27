#!/bin/bash

# E.g. when using *Max* to rip CDs, the resulting FLAC files can appear to
# be zero seconds long but still play fine.
# This script uses ffmpeg to copy the working files into a new file with
# the same name but with .flac.flac extension that fixes this issue. 

find . -name "*.flac" -exec ffmpeg -i {}  -c:v copy -c:a flac {}.flac \;