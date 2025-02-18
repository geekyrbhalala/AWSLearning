aws s3 ls --filters "Name=tag:Name,Values=dev-proj-1-jenkins-remote-state-bucket-5855"
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=dev-proj-jenkins-us-east-vpc-1" --output table
aws ec2 describe-subnets --filters "Name=tag:Name,Values=dev-proj*" --query "Subnets[*].[SubnetId, Tags[?Key=='Name'].Value | [0]]" --output table
aws ec2 describe-internet-gateways --output table