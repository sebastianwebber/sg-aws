require "json"

S3_BACKUP_BUCKET = "s3-demo-stackgres"
AWS_REGION = "us-east-2"
S3_BACKUP_BUCKET_USER = "#{S3_BACKUP_BUCKET}-user"

desc "setup s3 buckets"
task :setup_s3, [] do |t, args|
  policy = {
    "Version" => "2012-10-17",
    "Statement" => [
      {
        "Effect" => "Allow",
        "Action" => ["s3:ListBucket", "s3:GetBucketLocation"],
        "Resource" => ["arn:aws:s3:::#{S3_BACKUP_BUCKET}"],
      },
      {
        "Effect" => "Allow",
        "Action" => ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
        "Resource" => ["arn:aws:s3:::#{S3_BACKUP_BUCKET}/*"],
      },
    ],
  }

  common_args = {
    :region => AWS_REGION,
    "user-name" => S3_BACKUP_BUCKET_USER,
  }

  run "aws", "iam create-user", **common_args
  run "aws", "iam put-user-policy", **common_args, "policy-name" => "#{S3_BACKUP_BUCKET_USER}-policy", "policy-document" => policy.to_json

  run_multi %{
    aws iam create-access-key 
      #{process_args(common_args).join(" ")}
      --output json | tee bucket-creds.json
  }
end
