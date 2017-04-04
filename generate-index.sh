#!/bin/bash
#
# Copyright � 2015-2017, Akhil Narang "akhilnarang" <akhilnarang.1999@gmail.com>
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#

file="index.html"
[[ -f "${file}" ]] && echo "${file} already exists, please rename/remove" && exit 1;
touch ${file}
echo "
<table border=1>
<thead>
<tr>
<th>Sr. No.</th>
<th>Name [Click To Download]</th>
<th>md5sum</th>
<th>Size</th>
</tr>
</thead>
<tbody>
" >> ${file}
count=1
for f in $(ls)
do
  if [ -f "${f}" ];
  then
  filename=${f}
  filesize=$(du -sh ${f} | awk '{print $1}')
  filemd5=$(md5sum ${f} | cut -d ' ' -f 1)
  echo "
  <tr>
  <td>${count}</td>
  <td><a href=\"${filename}\">${filename}</a>
  <td>${filemd5}</td>
  <td>${filesize}</td>
  </tr>
  " >> ${file}
  count=$(($count + 1))
  fi
done
echo "
</tbody>
</table>
" >> ${file}
echo "Done :)"
