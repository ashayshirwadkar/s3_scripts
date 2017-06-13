#!/bin/bash -x

file=$1
upload_id=$2
bucket=$3

if [[ (-z "$1") || (-z "$2") || (-z "$3") ]]
  then
	echo "usage: ./object_complete_multipart <object_name> <upload_id> <bucket_name>"
	exit 1
fi

resource="/${bucket}/${file}?uploadId=${upload_id}"
contentType="application/text"
dateValue=`date -R`
stringToSign="POST\n\n${contentType}\n${dateValue}\n${resource}"
s3Key='AKIAJUULTKW33QH6Z6CQ'
s3Secret='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'
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
curl -v -X POST  \
	-H "Host: ${bucket}.s3.amazonaws.com" \
	-H "Date: ${dateValue}" \
	-H "Content-Type: ${contentType}" \
	-H "Authorization: AWS ${s3Key}:${signature}" \
	https://${bucket}.s3.amazonaws.com/${file}?uploadId=${upload_id} -d '

<CompleteMultipartUpload>
  <Part>
	<PartNumber>1</PartNumber>
	<ETag>79b281060d337b9b2b84ccf390adcf74</ETag>   # Add all the parts here.
  </Part>
</CompleteMultipartUpload>'
