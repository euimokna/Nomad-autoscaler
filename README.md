


## IAM권한 관련 
> https://www.nomadproject.io/tools/autoscaling/plugins/target/aws-asg
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:CreateOrUpdateTags",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}
```