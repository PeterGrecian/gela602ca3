# gela602ca3

s3 bucket A -> lambda -> s3 bucket B

lambda extracts and discards EXIF data from jpg files.

IAM user A Read/Write bucket A<br>
    user B Read bucket B

## Manifest:
### test.bash
test script to write .jpg to bucket A.  Uses aws cli and bash.

* as user A read from bucket A<br>
* assert existence of EXIF data in file.  Use "identify" from imagemagick.<br>
* as user B read from bucket B<br>
* assert non existance of EXIF data in file.<br>
* as user B fail to write to buckets A and B 

### update
upload lambda to AWS, quickly.

### deexim.py <file>
python to read file, discard EXIF data, write to path set by environment variable OUT_BUCKET

### lambda.py
python to invoke payload via lambda mechanism

### terraform/
* backend, provider, locals, gitinfo.bash
* s3.tf
* lambda.tf
* iam.tf
* role.tf   the policies attached to users A and B are attached to roles so they can
be tested via sts assume-role
* pil.zip   this should be maintained by terraform but I've run out of time, and requirements.tf_ is a stub
* requirements.txt python requirements for pip

    
