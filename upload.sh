#!/bin/bash
zip=$1
USER=afhftpuser
PASS=afh ftp pass
HOST=uploads.androidfilehost.com
curl --ftp-pasv $zip ftp://$USER:$PASS@$HOST
echo $zip uploaded to $HOST!
echo Deleting in 10 seconds press Control C to cancel deletion
sleep 10
rm -f $zip
