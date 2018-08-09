#!/bin/sh
echo "{"

for drive in sda sdb sdc sdd sde; do
    echo "  \"/dev/$drive\": {"

    # Get name and temperature
    rawtemp=$(/usr/sbin/hddtemp /dev/$drive 2>&1 | tail -n 1)
    hddname=$(echo $rawtemp | cut -d: -f2 | xargs)
    hddtemp=$(echo $rawtemp | cut -d: -f3 | xargs | sed -e 's/°C//g' -e 's/ C//g')
    echo "    \"name\": \"$hddname\","
    if [ "$hddtemp" -eq "$hddtemp" ] 2> /dev/null; then
        echo "    \"temp\": $hddtemp,"
    fi

    # Get SMART health
    smartstat=$(/usr/sbin/smartctl -H /dev/$drive \
        | awk '/START OF READ SMART DATA SECTION/{getline; print}' \
        | cut -d: -f2 | tr '[:upper:]' '[:lower:]' | xargs)
    echo "    \"smart\": \"$smartstat\""

    echo "  },"
done

fetchtime=$(date +%s)
echo "  \"time\": $fetchtime"

echo "}"
