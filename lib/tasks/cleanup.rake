desc "removes everything"
task :clean, [] do |t, args|
  Dir.glob("db-cluster/*.yml").sort_by do |f|
    File.basename(f, ".yml").delete("^0-9").to_i * -1
  end.each do |f|
    try_run "kubectl", "delete", :filename => f
  end
  try_run "helm", "uninstall", "stackgres-operator", :namespace => "stackgres"
  try_run "aws", "s3 rb", "s3://#{S3_BACKUP_BUCKET} --force"
  try_run "eksctl", "delete cluster", "--wait", :name => K8S_CLUSTER_NAME, :region => AWS_REGION

  common_args = {
    :region => AWS_REGION,
    "user-name" => S3_BACKUP_BUCKET_USER,
  }

  s3_creds_file = "./bucket-creds.json"
  if File.exists? s3_creds_file
    creds_file = JSON.parse(File.read(s3_creds_file))

    try_run "aws", "iam delete-user-policy", **common_args, "policy-name" => "#{S3_BACKUP_BUCKET_USER}-policy"
    try_run "aws", "iam delete-access-key", **common_args, "access-key-id" => creds_file["AccessKey"]["AccessKeyId"]
    try_run "aws", "iam delete-user", **common_args

    File.delete s3_creds_file
  end
end
