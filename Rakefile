Dir["./lib/*.rb"].sort.each { |f| require f }
Rake.add_rakelib "lib/tasks"

setup_deps = [
  :create_cluster,
  :setup_helm,
  :setup_monitoring,
  :setup_s3,
  :setup_stackgres,
]

desc "Install everything"
task :setup, [] => setup_deps do |t, args|
  puts "Done!"
end
