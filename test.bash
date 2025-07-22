#!/bin/bash

# these are too slow
# bucketA = $(terraform output -raw bucketA_name)
# bucketB = $(terraform output -raw bucketB_name)
tdir=test-data
bucketA="gela602ca3-bucket-a"
bucketB="gela602ca3-bucket-b"

function get_account_id() {
  aws sts get-caller-identity --query Account --output text
}  

function change_role() {
  local role_arn="$1"
  creds=$(aws sts assume-role --role-arn "$role_arn" --role-session-name "test-session")

  export AWS_ACCESS_KEY_ID=$(echo $creds | jq -r .Credentials.AccessKeyId)
  export AWS_SECRET_ACCESS_KEY=$(echo $creds | jq -r .Credentials.SecretAccessKey)
  export AWS_SESSION_TOKEN=$(echo $creds | jq -r .Credentials.SessionToken)  
  aws sts get-caller-identity
}

function default_creds() {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
  aws sts get-caller-identity
}

function test_account_permissions() {
 
  # as user A read/write /to bucket A
  local account_id=$(get_account_id)
  change_role "arn:aws:iam::$account_id:role/BucketAReadWriteRole"

  aws s3 ls s3://$bucketA
  f=$(mktemp -p ./)
  aws s3 cp $f s3://$bucketA/$f
  aws s3 cp s3://$bucketA/$f .
  aws s3 ls s3://$bucketA
  aws s3 rm s3://$bucketA/$f   # should fail

  default_creds
  aws s3 rm s3://$bucketA/$f   # but now it should succeed
  aws s3 cp $f s3://$bucketB/$f # should succeed

  # as user B read bucket B
  change_role "arn:aws:iam::$account_id:role/BucketBReadRole"

  aws s3 ls s3://$bucketB
  aws s3 cp s3://$bucketB/$f .
  aws s3 cp $f s3://$bucketB/$f # should fail
  echo "upload should have failed"

  # cleanup
  rm $f
  default_creds
  aws s3 rm s3://$bucketB/$f   # should succeed
}


function cleanup() {
  if [ -e test.jpg ]; then
    rm test.jpg
  fi
  aws s3 rm s3://$bucketA/test.jpg >& /dev/null
  aws s3 rm s3://$bucketB/test.jpg >& /dev/null
}


function has_exif() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "File not found: $file"
    return 1
  fi
  if identify "$file" | grep -qi exif; then
    return 0
  else
    return 1
  fi
}


function test_exifs() {
  dir=test-data
  f="$dir/test.jpg"
  if has_exif "test.jpg"; then
    echo "ERROR: No EXIF data found in $f"
  else
    echo "OK: EXIF data found in $f"
  fi

  f="$dir/noexif.jpg"
  if has_exif "noexif.jpg"; then
    echo "OK: No EXIF data found in $f"
  else
    echo "ERROR: EXIF data found in $f"
  fi
}

function test_lambda () {
  cleanup >& /dev/null

  aws s3 cp $tdir/test.jpg s3://$bucketA/test.jpg
  sleep 10
  aws s3 cp s3://$bucketB/test.jpg .
  if has_exif "test.jpg"; then
    echo "ERROR: EXIF data found in test.jpg"
  else
    echo "OK: No EXIF data found in test.jpg"
  fi

  cleanup >& /dev/null() {
  cleanup >& /dev/null

  aws s3 cp $tdir/test.jpg s3://$bucketA/test.jpg
  sleep 10
  aws s3 cp s3://$bucketB/test.jpg .
  if has_exif "test.jpg"; then
    echo "ERROR: EXIF data found in test.jpg"
  else
    echo "OK: No EXIF data found in test.jpg"
  fi

  cleanup >& /dev/null

}