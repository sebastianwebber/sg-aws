require "json"

desc "execute a random restart in the cluster"
task :execute_restarts, [] do |t, args|
  begin
    all_ops = %x[kubectl get sgdbops -o name].split("\n")
    last = all_ops.select do |op|
      op.start_with? "sgdbops.stackgres.io/restart"
    end.sort_by do |op|
      op
    end.last

    last_id = last.split("/").last.delete("^0-9").to_i
  rescue => exception
    last_id = 0
  end

  next_id = last_id + 1

  new_op = {
    :apiVersion => "stackgres.io/v1",
    :kind => "SGDbOps",
    :metadata => {
      :name => "restart#{next_id}",
    },
    :spec => {
      :maxRetries => 1,
      :op => "restart",
      :sgCluster => "my-db-cluster",
      :restart => {
        :method => "InPlace",
      },
    },
  }

  # echo '#{new_op.to_json}' | jq
  run_multi %{
    echo '#{new_op.to_json}' | kubectl apply -f -
  }
end
