#!/bin/sh

input_file="/proxylist.conf"
output_file="/etc/nginx/conf.d/generated.conf"
skeleton_file="/etc/nginx/conf.d/skel.conf"

while read input; do
  # Parse input arguments
  xscript_prefix=$(echo $input | cut -d '|' -f 1)
  origin=$(echo $input | cut -d '|' -f 2)
  origin_prefix=$(echo $input | cut -d '|' -f 3)

  origin_host=$(echo $origin | cut -d ':' -f 1)
  origin_port=$(echo $origin | cut -d ':' -f 2)

  # Log what I'm doing
  echo "  $xscript_prefix >> localhost:$origin_port$origin_prefix"

  # Generate configuration from skel.conf
  sed -e "s#@XScriptName@#$xscript_prefix#g" \
      -e "s#@OriginHost@#$origin_host#" \
      -e "s#@OriginPort@#$origin_port#" \
      -e "s#@OriginPrefix@#$origin_prefix#" \
      $skeleton_file >> $output_file
done < $input_file
