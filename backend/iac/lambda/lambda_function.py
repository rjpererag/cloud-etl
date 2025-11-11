# lambda_handler.py

import json
import os
import boto3

# --- Configuration (Pulled from Lambda Environment Variables) ---
# NOTE: You must have set these Environment Variables in your Lambda function configuration!
ECS_CLUSTER_NAME = os.environ.get('ECS_CLUSTER_NAME')
ECS_TASK_FAMILY = os.environ.get('ECS_TASK_FAMILY')
VPC_SUBNET_IDS = os.environ.get('VPC_SUBNET_IDS').split(',')  # Convert comma-separated string to list
ECS_SECURITY_GROUP = os.environ.get('ECS_SECURITY_GROUP')

# Initialize the ECS client
ecs_client = boto3.client('ecs')
# Initialize the S3 client for potentially reading metadata, though not strictly needed here
s3_client = boto3.client('s3')


def lambda_handler(event, context):
    """
    AWS Lambda handler function triggered by S3 ObjectCreated events.
    It parses the event and launches an ECS Fargate task for transformation.
    """
    print("--- Lambda Invoked by S3 Event ---")

    try:
        record = event['Records'][0]
        bucket_name = record['s3']['bucket']['name']
        file_key = record['s3']['object']['key']

        print(f"Detected new object: s3://{bucket_name}/{file_key}")

    except (KeyError, IndexError) as e:
        print(f"Error parsing S3 event structure: {e}")
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Invalid S3 event structure'})
        }

    container_overrides = {
        'name': 'transformation-container',
        'environment': [
            {'name': 'S3_RAW_KEY', 'value': file_key},
        ],
    }

    try:
        response = ecs_client.run_task(
            cluster=ECS_CLUSTER_NAME,
            taskDefinition=ECS_TASK_FAMILY,
            launchType='FARGATE',
            count=1,
            networkConfiguration={
                'awsvpcConfiguration': {
                    'subnets': VPC_SUBNET_IDS,
                    'securityGroups': [ECS_SECURITY_GROUP],
                    'assignPublicIp': 'ENABLED'
                }
            },
            overrides={
                'containerOverrides': [container_overrides]
            }
        )

        task_arn = response['tasks'][0]['taskArn']
        print(f"Successfully launched ECS Fargate Task: {task_arn}")

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'ECS Fargate task launched successfully', 'task_arn': task_arn})
        }

    except Exception as e:
        print(f"Error launching ECS Fargate task: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Failed to launch ECS task', 'error': str(e)})
        }