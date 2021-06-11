K8S_CLUSTER_NAME = "stackgres"

desc "Creates the aws cluster"
task :create_cluster, [] do |t, args|
  run_multi %{
    eksctl --region #{AWS_REGION} create cluster
      --name #{K8S_CLUSTER_NAME}
      --node-type m5a.2xlarge --node-volume-size 100 --nodes 3
      --zones #{AWS_REGION}a,#{AWS_REGION}b,#{AWS_REGION}c
      --version 1.19
  }
end
