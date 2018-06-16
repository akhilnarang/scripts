#!/usr/bin/env bash

# Random script that outputs an index.html with a table containing the files in the current dir

file="index.html"
[[ -f "${file}" ]] && echo "${file} already exists, please rename/remove" && exit 1
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
  if [ -f "${f}" ]
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
