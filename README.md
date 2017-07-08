# S3 Scripts
## Information
Shell scripts to access amazon S3 using both signature version 2 and 4.

Following shell scripts are present at this moment (for v2 and v4):
* Create bucket
* List bucket
* Delete bucket
* Put object
* Get object
* Delete object

In addition to this, multipart request shell scripts are there for v2
* Create multipart
* Upload parts
* Complete multipart

## Script usage
```
./<script_name> <required params>
```
## Limitations
* Can not parse user defined metadata while putting object. (Although you can modify shell script directly, please check shell script [put-object.sh](https://github.com/ashayshirwadkar/s3_scripts/blob/master/s3/v4/put_object.sh) for V4)
* **us-east-1** region is not supported.
