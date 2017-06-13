#!/bin/bash -x

file=$1
upload_id=$2
PartNo=$3
bucket=$4

if [[ (-z "$1") || (-z "$2") || (-z "$3") || (-z "$4")]]
  then
	echo "usage: ./object_multipart_upload <object_name> <upload_id> <part number> <bucket_name>"
	exit 1
fi

resource="/${bucket}/${file}?partNumber=${PartNo}&uploadId=${upload_id}"
contentType="application/text"
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
s3Key='AKIAJUULTKW33QH6Z6CQ'
s3Secret='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'
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
curl -v -X PUT -T "${file}" \
	-H "Host: ${bucket}.s3.amazonaws.com" \
	-H "Date: ${dateValue}" \
	-H "Content-Type: ${contentType}" \
	-H "Content-Length: 5242880" \
	-H "Authorization: AWS ${s3Key}:${signature}" \
	https://${bucket}.s3.amazonaws.com/${file}?partNumber=${PartNo}\&uploadId=${upload_id}
