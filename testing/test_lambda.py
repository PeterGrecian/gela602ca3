import os, sys
import time

sys.path.append('../general-awspy')
from s3_commands import *

def is_image(file):
    """
    Check if the file is a valid image by trying to open it with PIL.
    Returns True if the file is a valid image, False otherwise.
    """
    from PIL import Image
    try:
        img = Image.open(file)
        img.verify()  # Verify that it is an image
        return img
    except Exception as e:
        print(f"Error opening image: {e}")
        return False

def has_exif(img):
    try:
        exif_data = img._getexif()
        if exif_data is None:
            return False
        else:
            return True
    except Exception as e:
        print(f"Error checking EXIF data: {e}")
        return False # unlikely as the file verified

def check_image_file(local_image, expect_exif=True):
    """
    Check if the file is a valid image and has EXIF data.
    """
    assert os.path.exists(local_image), f"Local image {local_image} does not exist." 
    assert os.access(local_image, os.R_OK), f"Local image {local_image} is not readable."
    img = is_image(local_image)
    assert img, f"{local_image} is corrupted." 
    if expect_exif:  
        assert has_exif(img), f"Local image {local_image} does not have EXIF data."
    else:
        assert not has_exif(img), f"Local image {local_image} should not have EXIF data."

  
def test_lambda():
    """
    """
    awhile = 1 # seconds
    bucketA = "gela602ca3-bucket-a"
    bucketB = "gela602ca3-bucket-b"
    file = "test.jpg"
    data_dir = "test-data"

    # cleanup in case the last test was interrupted
    rm_all(bucketA)
    rm_all(bucketB)


    local_image = os.path.join(data_dir, file)
    check_image_file(local_image, expect_exif=True)

    # create the file which triggers the lambda
    cp(local_image, bucketA, file) # to bucket
    while file not in ls(bucketB): 
        #print("Waiting for file to be processed...")
        time.sleep(awhile)

    time.sleep(awhile)  # wait for lambda to completely process the file
    # this is potentially a source of flakiness
    # could be improved by checking the cloudwatch logs for the lambda

    import tempfile
    fileback = "/tmp/" + next(tempfile._get_candidate_names()) + ".jpg"
    cp_back(bucketB, file, fileback) # from bucket
    check_image_file(fileback, expect_exif=False)

    # cleanup
    os.remove(fileback)  
    rm_all(bucketA)
    rm_all(bucketB)


sts = boto3.client('sts')

def test_permissions():
    roleA = "arn:aws:iam::$account_id:role/BucketAReadWriteRole"
    roleB = "arn:aws:iam::$account_id:role/BucketBReadRole"

    response = sts.assume_role(RoleArn=roleA, RoleSessionName="test-session") 
    from pprint import pprint
    pprint(response)
    assert False, "This test is not implemented yet. It should check the permissions of the S3 buckets and the Lambda function."