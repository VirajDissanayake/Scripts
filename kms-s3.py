import boto3
import logging
from cryptography.fernet import Fernet
from botocore.exceptions import ClientError
import base64

NUM_BYTES_FOR_LEN = 4

def create_data_key(cmk_id, key_spec='AES_256'):
    kms = boto3.client('kms')
    try:
        response = kms.generate_data_key(KeyId=cmk_id, KeySpec=key_spec)
    except ClientError as e:
        logging.error(e)
        return None, None
    return response['CiphertextBlob'], base64.b64encode(response['Plaintext'])

def encrypt_file(finename, cmk_id):
    try:
        with open(finename, 'rb') as file:
            content = file.read()
    except IOError as e:
        logging.error(e)
        return False
    
    data_key_encrypted, data_key_plaintext = create_data_key(cmk_id)
    f = Fernet(data_key_plaintext)
    encrypted_content = f.encrypt(content)

    try:
        with open('encrypted_file.txt', 'wb') as enc_file:
            enc_file.write(len(data_key_encrypted).to_bytes(NUM_BYTES_FOR_LEN, byteorder='big'))
            enc_file.write(data_key_encrypted)
            enc_file.write(encrypted_content)
            upload_to_s3(enc_file)
    except IOError as e:
        logging.error(e)
        return False

def upload_to_s3(filename):
    s3 = boto3.client('s3')
    try:
        s3.upload_file(filename, 'testbucket', 'testfile')
    except ClientError as e:
        logging.error(e)
    return True