#!/bin/bash -x 

file=$1
bucket=$2

if [[ (-z "$1") || (-z "$2") ]]
then
	echo "usage: ./file_upload <file_name> <bucket_name> "
	exit 1
fi

resource="/${bucket}/${file}"
contentType="application/x-compressed-tar"
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
s3Key='AKIAJUULTKW33QH6Z6CQ'
s3Secret='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'
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
curl -X PUT -T "${file}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  https://${bucket}.s3.amazonaws.com/${file}
