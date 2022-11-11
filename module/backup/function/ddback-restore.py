import datetime
import json
import boto3
import urllib3

#Initialize boto client for AWS Backup
backup = boto3.client('backup')

def lambda_handler(event, context):
    #Print the incoming event
    print('Incoming Event:' + json.dumps(event))

    input_event = event

    #Determine job type based on event - backup completed vs restore completed
    job_type = event['detail-type'].split(' ')[0]

    #Print the job type
    print(job_type + ' job completed')


    try:
        if job_type == 'Backup':
            handleBackup(input_event)
        elif job_type == 'Restore':
            handleRestore(input_event)
    except Exception as e:
        print(str(e))
        return

def handleBackup(input_event):
    #Get backup job ID from incoming event
    backup_job_id = input_event['detail']['backupJobId']
    print('Backup job ID: ' + backup_job_id)

    #Get backup job details
    backup_info = backup.describe_backup_job(
                    BackupJobId=backup_job_id
                )
    print(backup_info)
    recovery_point_arn = backup_info['RecoveryPointArn']
    iam_role_arn = backup_info['IamRoleArn']
    backup_vault_name = backup_info['BackupVaultName']
    print('Recovery point ARN: ' + recovery_point_arn)
    print('IAM role ARN: ' + iam_role_arn)
    print('Backup vault name: ' + backup_vault_name)

    #Get recovery point restore metadata
    print('Retrieving recovery point restore metadata')
    metadata = backup.get_recovery_point_restore_metadata(
        BackupVaultName=backup_vault_name,
        RecoveryPointArn=recovery_point_arn
    )

    #Set values for restore metadata
    print('Setting restore metadata values')
    metadata['RestoreMetadata']['targetTableName'] = 'vault-lambda-restore'
    print(metadata)

    #API call to start the restore job
    print('Starting the restore job')
    restore_request = backup.start_restore_job(
            RecoveryPointArn=recovery_point_arn,
            IamRoleArn=iam_role_arn,
            Metadata=metadata['RestoreMetadata']
    )

    print(json.dumps(restore_request))
    print("completed restore------------------")

    return



def handleRestore(input_event):
    #Get restore job ID from incoming event
    restore_job_id = input_event['detail']['restoreJobId']
    print('Restore job ID: ' + restore_job_id)

    #Get restore job details
    restore_info = backup.describe_restore_job(
                    RestoreJobId=restore_job_id
                )

    print('Restore from the backup was successful')
    print(restore_info)