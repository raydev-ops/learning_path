# How to Setup and Push Server and Application Logs to AWS Cloudwatch

AWS cloudwatch logs service can store custom logs generated from you applications instances. It acts as a central log management for your applications running on AWS.

You can send logs from any number of sources to cloudwatch.

To setup AWS custom logs, first, you need to create and add an IAM role to your instance. This IAM role will have write access to cloudwatch so that all the logs can be shipped to cloudwatch.
Create an IAM role for Cloudwatch

Before creating a role, you need to create a custom policy.

1. Head over to AWS IAM –> Policy –> Create Policy

2. Select oCreate your own policy

3. In the next page, give a name and description for your policy and copy the following content in the policy block and click create policy option.

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
 ]
}

```

Once you create the policy, you need to create a role with the custom policy you have created.

1. Head over to AWS IAM –> Roles –> Create New Role and give it a name `CloudWatchLogs`.
2. Click next and select, Amazon EC2.
3. Click the filter dropdown and select Customer Managed option and then select the policy you have created.

4. Click next and then choose create role option.
Add the Cloudwatch Role to the Instance

1. Now, head over to ec2 and select the instanc in which you want to configure the custom logs.

2. Right click for options and select Instance Settings and then choose Attach/Replace IAM Role option.

3. On the next page, select the IAM role from the dropdown and choose to apply.
Setup AWSlogs agent

ssh into the instance and follow the steps given below.

1. Down the agent Setup
	
` curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O `

2. Execute the python script with your AWS region as a parameter.
	
` sudo python ./awslogs-agent-setup.py --region us-west-1 `

The above script will ask for log file location other options for managing logs in cloudwatch. Hit enter when asked for access key and secret key. Since we are using IAM roles, by default, the instance has cloudwatch write permissions.

Provide valid log path files and custom names fo identifying it in the cloudwatch dashboard. [![The parameter reference is shown below](https://github.com/veeru538/learning_path/blob/master/image.png)]

Except Ubuntu 16.04 in all other Linux systems, the above script will create a service. So that you can manage the aws logs agent using the following commands.

In Ubuntu 16.04, for setting up awslogs as a service, you can follow this article.

```	
sudo service awslogs start
sudo service awslogs stop
sudo service awslogs restart

```

All the aws logs config files and startup scripts can be found under `/var/awslogs ` folder.

You can add additional log configs in the `/var/awslogs/etc/awslogs.conf` file. After making the changes, make sure you restart the agent.

AWS specific configuration can be edited in `/var/awslogs/etc/aws.conf` file.

The agent start and other scripts can be found under `/var/awslogs/bin` folder.

Once the setup is done, you can view all the configured logs under cloudwatch dashboard (under logs option)

