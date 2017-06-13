#!/bin/bash -x

bucket=$1

if [ -z "$1" ]
  then
	echo "usage: ./list_bucket <bucket_name>"
	exit 1
fi

resource="/${bucket}/"
dateValue=`date -R`
stringToSign="GET\n\n\n${dateValue}\n${resource}"
s3Key='AKIAJUULTKW33QH6Z6CQ'
s3Secret='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'
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
curl -v -X GET -H "Host: ${bucket}.s3.amazonaws.com" -H "Date: ${dateValue}" \
  -H "Authorization: AWS ${s3Key}:${signature}" https://${bucket}.s3.amazonaws.com/

