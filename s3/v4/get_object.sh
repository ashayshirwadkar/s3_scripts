#!/bin/sh -x
if [ -z "$2" ]
then
    echo "usage: ./get_object <bucket_name> <object_name>"
    exit 1
fi

bucket=$1
object=$2

timestamp=$(date -u "+%Y-%m-%d %H:%M:%S")
isoTimestamp=$(date -ud "${timestamp}" "+%Y%m%dT%H%M%SZ")
dateScope=$(date -ud "${timestamp}" "+%Y%m%d")
region="us-east-1"

# Process of getting String to sign
payload=$(echo -en ${data} | openssl dgst -sha256 | sed 's/^.* //')
canonical_req="GET\n/${object}\n\nhost:${bucket}.s3.amazonaws.com\nx-amz-content-sha256:${payload}\nx-amz-date:${isoTimestamp}\n\nhost;x-amz-author;x-amz-content-sha256;x-amz-date\n${payload}"

hash_canonical=$(echo -en ${canonical_req} | openssl dgst -sha256 | sed 's/^.* //')


stringtosign="AWS4-HMAC-SHA256\n${isoTimestamp}\n${dateScope}/${region}/s3/aws4_request\n${hash_canonical}"

# Generating signing key
hmac_sha256() {
  key=$1
  data=$2
  echo -en "$data" | openssl dgst -sha256 -mac HMAC -macopt "$key" | sed 's/^.* //'
}

s3Key="aaaaaaaaaaaaaa" #Access key
secret="bbbbbbbbbbbbb" #Secret Access key

date=${dateScope}
service="s3"

# Four-step signing key calculation
dateKey=$(hmac_sha256 key:"AWS4$secret" $date)

echo "dateKey" $dateKey

dateRegionKey=$(hmac_sha256 hexkey:$dateKey $region)

echo "dateRegionKey" $dateRegionKey
dateRegionServiceKey=$(hmac_sha256 hexkey:$dateRegionKey $service)

echo "dateRegionServiceKey" $dateRegionServiceKey
signingKey=$(hmac_sha256 hexkey:$dateRegionServiceKey "aws4_request")

echo "Value of signing key is" $signingKey

# Signature calculated using string_to_sign and signing key
calc_sign=$(echo -en ${stringtosign} | openssl dgst -sha256 -mac HMAC -macopt hexkey:${signingKey} | sed 's/^.* //')
echo $calc_sign

# Create auth header

cred="${s3Key}/${dateScope}/${region}/s3/aws4_request"
signedHeaders="host;x-amz-content-sha256;x-amz-date"
auth_header="AWS4-HMAC-SHA256 Credential= ${cred}, SignedHeaders=${signedHeaders}, Signature=${calc_sign}" 

# Final request
curl -v -X GET https://${bucket}.s3.amazonaws.com/${object} \
    -H "Authorization: AWS4-HMAC-SHA256 \
         Credential=${cred}, \
         SignedHeaders=${signedHeaders}, \
         Signature=${calc_sign}" \
    -H "x-amz-content-sha256: ${payload}" \
    -H "x-amz-date: ${isoTimestamp}"


