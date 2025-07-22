# gela602ca3

s3 bucket A -> lambda -> s3 bucket B

lambda extracts and discards EXIF data from jpg files.

IAM user A Read/Write bucket A<br>
    user B Read bucket B

## Manifest:
### test.bash
test script to write .jpg to bucket A.  Uses aws cli/bash.

* as user A read from bucket A<br>
* assert existance of EXIF data in file.  Use "identify" from imagemagick.<br>
* as user B read from bucket B<br>
* assert non existance of EXIF data in file.<br>
* as user B fail to write to buckets A and B 

### deexim.py <file>
python to read file, discard EXIF data, write to path set by environment variable B_BUCKET

### lambda.py
python to invoke payload via lambda mechanism

### terraform/
* backend, provider, locals, gitinfo.bash
* s3.tf
* lambda.tf
* iam.tf

    
