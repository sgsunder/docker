#!/bin/sh
# Copyright (c) 2018 Shyam Sunder
output_file="/etc/nginx/conf.d/generated.conf"

# File Template
skeleton_file=$(mktemp)
cat << 'EOF' > $skeleton_file
location @XScriptName@ {
    proxy_http_version 1.1;
    proxy_pass http://@OriginHost@:@OriginPort@@OriginPrefix@;

    proxy_set_header Host              $http_host;
    proxy_set_header Upgrade           $http_upgrade;
    proxy_set_header Connection        "upgrade";
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header X-Scheme          $scheme;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Script-Name     @XScriptName@;
}
EOF

# Generate configs
for varname in $(env | awk -F "=" '{print $1}' | grep -i "proxy_*"); do
  eval "input=\$$varname"
  # Parse input arguments
  xscript_prefix=$(echo $input | cut -d '|' -f 1)
  origin=$(echo $input | cut -d '|' -f 2)
  origin_prefix=$(echo $input | cut -d '|' -f 3)

  origin_host=$(echo $origin | cut -d ':' -f 1)
  origin_port=$(echo $origin | cut -d ':' -f 2)

  # Log what I'm doing
  echo "  $xscript_prefix >> $origin_host:$origin_port$origin_prefix"

  # Generate configuration from skeleton_file
  sed -e "s#@XScriptName@#$xscript_prefix#g" \
      -e "s#@OriginHost@#$origin_host#" \
      -e "s#@OriginPort@#$origin_port#" \
      -e "s#@OriginPrefix@#$origin_prefix#" \
      $skeleton_file >> $output_file
done

rm -f $skeleton_file

nginx -g "daemon off;"
