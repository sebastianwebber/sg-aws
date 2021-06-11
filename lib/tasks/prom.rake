desc "setup monitoring"
task :setup_monitoring, [] do |t, args|
  run "kubectl", "create namespace", "monitoring"

  set_args = [
    "grafana.enabled=true",
    "prometheusOperator.createCustomResource=false",
  ]
  run "helm", "install", "prometheus", "prometheus-community/kube-prometheus-stack --disable-openapi-validation", :namespace => "monitoring", "set" => set_args, :version => "13.4.0"
end
