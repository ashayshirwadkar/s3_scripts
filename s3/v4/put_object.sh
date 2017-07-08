 #!/bin/sh -x
usage() { echo "Usage: $0 [-b <bucket_name>] [-o <object_name>] [-r <region>] [-a <access_key>] [-s <secret_access_key>]" 1>&2; exit 1; }

while getopts ":b:r:a:s:o:" opt; do
    case "${opt}" in
        b)
            bucket=${OPTARG}
            ;;
        o)
            object=${OPTARG}
            ;;
        r)
            region=${OPTARG}
            ;;
        a)
            s3Key=${OPTARG}
            ;;
        s)
            secret=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${bucket}" ] || [ -z "${object}" ]|| [ -z "${region}" ] || [ -z "${s3Key}" ] || [ -z "${secret}" ]; then
    usage
fi

data=`cat $object`
timestamp=$(date -u "+%Y-%m-%d %H:%M:%S")
isoTimestamp=$(date -ud "${timestamp}" "+%Y%m%dT%H%M%SZ")
dateScope=$(date -ud "${timestamp}" "+%Y%m%d")

# Process of getting String to sign
payload=$(echo -en ${data} | openssl dgst -sha256 | sed 's/^.* //')
canonical_req="PUT\n/${object}\n\ncontent-type:application/text\nhost:${bucket}.s3-${region}.amazonaws.com\nx-amz-content-sha256:${payload}\nx-amz-date:${isoTimestamp}\nx-amz-meta-author:xyz\n\ncontent-type;host;x-amz-content-sha256;x-amz-date;x-amz-meta-author\n${payload}"

hash_canonical=$(echo -en ${canonical_req} | openssl dgst -sha256 | sed 's/^.* //')

stringtosign="AWS4-HMAC-SHA256\n${isoTimestamp}\n${dateScope}/${region}/s3/aws4_request\n${hash_canonical}"

# Generating signing key
hmac_sha256() {
  key=$1
  data=$2
  echo -en "$data" | openssl dgst -sha256 -mac HMAC -macopt "$key" | sed 's/^.* //'
}

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
signedHeaders="content-type;host;x-amz-content-sha256;x-amz-date;x-amz-meta-author;"
auth_header="AWS4-HMAC-SHA256 Credential= ${cred}, SignedHeaders=${signedHeaders}, Signature=${calc_sign}" 

# Final request
curl -v -X PUT https://${bucket}.s3-${region}.amazonaws.com/${object} \
    -H "Authorization: AWS4-HMAC-SHA256 \
         Credential=${cred}, \
         SignedHeaders=${signedHeaders}, \
         Signature=${calc_sign}" \
    -H "x-amz-content-sha256: ${payload}" \
    -H "Content-Type: application/text" \
    -H "x-amz-meta-author: xyz" \
    -H "x-amz-date: ${isoTimestamp}" -d "${data}"


