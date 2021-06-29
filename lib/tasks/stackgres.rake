require "json"

SG_VERSION = "1.0.0-alpha4"
UI_PASSWD = "password"

desc "setup stackgres"
task :setup_stackgres, [] do |t, args|
  run "kubectl", "create namespace", "stackgres"

  chart_url = "https://stackgres.io/downloads/stackgres-k8s/stackgres/#{SG_VERSION}/helm/stackgres-operator.tgz"

  str_args = [
    "grafana.webHost=prometheus-grafana.monitoring",
    "grafana.user=admin",
    "grafana.password=prom-operator",
    "adminui.service.type=LoadBalancer",
    "prometheus.allowAutobind=true",
    "authentication.password=#{UI_PASSWD}",
  ]
  run "helm", "install", "stackgres-operator", chart_url, :namespace => "stackgres", "set" => "grafana.autoEmbed=true", "set-string" => str_args
end

desc "deploy the database"
task :deploy_database, [] => [:deploy_s3_creds] do |t, args|
  Dir.glob("db-cluster/*.yml").sort_by do |f|
    File.basename(f, ".yml").delete("^0-9").to_i
  end.each do |f|
    run "kubectl", "apply", :filename => f
  end
end

desc "config s3 secrets"
task :deploy_s3_creds, [] do |t, args|
  creds_file = JSON.parse(File.read("./bucket-creds.json"))

  creds = {
    :apiVersion => "v1",
    :kind => "Secret",
    :metadata => {
      :name => "aws-creds-secret",
    },
    :type => "Opaque",
    :data => {
      "accessKeyId" => creds_file["AccessKey"]["AccessKeyId"],
      "secretAccessKey" => creds_file["AccessKey"]["SecretAccessKey"],
    },
  }

  run_multi %{
    echo '#{creds.to_json}' | kubectl apply -f -
  }
end
