#!/bin/bash -x

file=$1
bucket=$2

if [[ (-z "$1") || (-z "$2") ]]
then
	echo "usage: ./object_initiate_multipart <object_name> <bucket_name>"
	exit 1
fi

resource="/${bucket}/${file}?uploads"
contentType="application/text"
dateValue=`date -R`
stringToSign="POST\n\n\n${dateValue}\n${resource}"
s3Key='AKIAJUULTKW33QH6Z6CQ'
s3Secret='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'
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
curl -v -X POST  \
	-H "Host: ${bucket}.s3.amazonaws.com" \
	-H "Date: ${dateValue}" \
	-H "Authorization: AWS ${s3Key}:${signature}" \
	https://${bucket}.s3.amazonaws.com/${file}?uploads

