#!/bin/bash

# these are too slow
# bucketA = $(terraform output -raw bucketA_name)
# bucketB = $(terraform output -raw bucketB_name)
tdir=test-data
bucketA="gela602ca3-bucket-a"
bucketB="gela602ca3-bucket-b"

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