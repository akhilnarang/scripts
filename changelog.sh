#!/bin/bash
cwd=$PWD
export device="bullhead"
cd ${KERNELDIR}/$device
export changelog=${KERNELDIR}/misc/$device.changelog
echo "Changelog for the past 10 months:" > $changelog
for i in $(seq 300); do
    export After_Date=$(date --date="$i days ago" +%m-%d-%Y);
    export Until_Date=$(date --date="$(expr $i - 1) days ago" +%m-%d-%Y);

    # Line with after --- until was too long for a small ListView
    echo ${ylw}"  Processing $Until_Date..."${txtrst};
    echo ' ======================' >> "$changelog";
    echo '  ChangeLog '$Until_Date >> "$changelog";
    echo ' ======================' >> "$changelog";

    # Handle the usage of repochangelog days_count project1_path,project2_path,...
          echo "" >> "$changelog";
          git log --oneline --pretty="tformat:    %h - %s <%an>" --after=${After_Date} --until=${Until_Date} >> "$changelog";

done
