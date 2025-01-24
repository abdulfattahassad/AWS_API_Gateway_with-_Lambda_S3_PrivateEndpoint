# enable_dns_hostnames:
This setting controls whether the DNS hostnames are automatically assigned to instances that are launched in the VPC.
If enable_dns_hostnames = true, instances launched in the VPC will have a DNS hostname (e.g., ip-172-31-XX-XX.ec2.internal).
If enable_dns_hostnames = false, instances will not automatically have DNS hostnames.
# enable_dns_support:
This setting determines whether DNS resolution is enabled in the VPC.
If enable_dns_support = true, the VPC will support DNS resolution.
If enable_dns_support = false, DNS resolution will be disabled for the VPC.
# when we integrate lambda function with API gateway ,  Resource Policy in lambda function under permission section in lambda will be created automatically 

# Two more actions required :
 1-  create resource policy in api gateway  in order to be used via any sources  conain api-invoke
 2-  create IAM role in lambda function and assoicate with it under exectuion role in order to access S3 bucket
 3- EC2 require IAM role to access API Gateway
 4- enable private dns  for endpoint interface via going to edit private dns name  which effect on interface endpoint state  ===NOT RELATED .. so we can remove it

 # API in API gateway  has same format for all types ...
 
# E2 IAM Role to access API GW

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "execute-api:Invoke"
            ],
            "Resource": "arn:aws:execute-api:us-east-1:992382750911:tr517nrebc/*"
        }
    ]
}

# IMPORTANT NOTE:  API URL should include Stage then Resource , otherwise you will receive missing token ... the easiest wya is to use CURL  , otherwise , if you enable "API key" you need to use request packege including the header ... if you use authorization in api gateway -- it will be called IAM authorization based.
