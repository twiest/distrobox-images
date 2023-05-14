#!/bin/bash

# exit on failure
set -euo pipefail

standard_extension="--- volume fixed.mp4"
extra_options=""
extra_input_options=""
extra_output_options=""

# Check for quicksync
if /bin/false; then  # SKIP FOR NOW
#if ffmpeg -encoders | grep h264_qsv &> /dev/null; then
  extra_options="$extra_options -init_hw_device qsv=hw -filter_hw_device"
  extra_output_options="$extra_output_options -c:v h264_qsv"
fi

# increase brightness too
#extra_options="-vf eq=brightness=0.10:saturation=5"

#cd "$(dirname $0)/../daily/"

for file_encoded in $(ls | tr ' ' ''); do
   echo "-------------------------------------------------------------------------------------------------------"
   file=$(echo $file_encoded | tr '' ' ')
   file_wo_extension="${file%.*}"
   file_extension="${file##*.}"
   file_new_name="${file_wo_extension} ${standard_extension}"

   if [ -d "$file" ]; then
     continue
   fi

   if [ "$file_extension" == "jpg"   -o \
	 "$file_extension" == "jpeg" -o \
	 "$file_extension" == "JPG"  -o \
	 "$file_extension" == "JPEG" -o \
	 "$file_extension" == "png"  -o \
	 "$file_extension" == "PNG"  -o \
	 "$file_extension" == "gif"  -o \
	 "$file_extension" == "GIF" ]; then
      echo "Skipping picture [$file]."
      continue
   fi

   if [ "$file_extension" == "sh" ]; then
      echo "Skipping script [$file]."
      continue
   fi

   if [ -f "$file_new_name" ] || [[ "$file" =~ "${standard_extension}" ]]; then
     echo "Skipping already converted file [$file]."
     continue
   fi

   duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal "$file")
   input_duration_in_sec=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file")

   echo
   echo "Duration [$duration] of [$file]."
   time ffmpeg $extra_options -v warning -hide_banner -stats $extra_input_options $extra_input_options -i "$file" -filter:a "volume=10" $extra_output_options "$file_new_name"
   output_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal "$file_new_name")

   echo
   echo
   echo "Duration [$duration] of [$file]."
   echo "Duration [$output_duration] of [$file_new_name]."
   echo



   output_duration_in_sec=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file_new_name")

   #diff_duration=$(( input_duration_in_sec - output_duration_in_sec ))
   #echo "$input_duration_in_sec - $output_duration_in_sec = $diff_duration"
   #if [ $diff_duration -gt 1 ]; then
   #  echo "Moving length too short on [$file_new_name]."
   #  exit 5
   #fi



   # FOR DEBUGGING ONLY
   #echo "only 1 loop for testing" && exit
done
