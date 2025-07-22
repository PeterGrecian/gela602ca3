
def strip(bucket, file):
    print(bucket, file)

    """
    Read the file from the specified S3 bucket, strip EXIM data, and write the modified file back to the bucket.
    """
    import boto3
    import os
    from PIL import Image
    from io import BytesIO

    print("s3 client")
    s3 = boto3.client('s3')
    
    # Read the file from S3
    infile = f"{bucket}/{file}"
    outfile = f"{os.environ['OUTPUT_BUCKET']}/{file}"

    print(f"Reading file from {infile}")
    response = s3.get_object(Bucket=bucket, Key=file)
    print("READ")
    file_content = response['Body'].read()
    print("DATA READ")

    # Open the image using PIL (Python Imaging Library)
    image = Image.open(BytesIO(file_content))

    
    # next 3 lines strip exif
    data = list(image.getdata())
    image_without_exif = Image.new(image.mode, image.size)
    image_without_exif.putdata(data)

    # Save image to an in-memory buffer
    buffer = BytesIO()
    image_without_exif.save(buffer, format='JPEG')
    buffer.seek(0)  # Reset buffer position to the beginning

    # Write the modified content back to S3
    print(f"Writing stripped file to {os.environ['OUTPUT_BUCKET']}/{file}")
    s3.put_object(
        Bucket=os.environ['OUTPUT_BUCKET'], 
        Key=file, 
        Body=buffer,
        ContentType='image/jpeg'
    )
    print(f"Stripped file written to {outfile}")

if __name__ == "__main__":
    strip('gela602ca3-bucket-a', 'test.jpg')