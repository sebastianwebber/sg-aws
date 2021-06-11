def try_run(*cmd, **args)
  begin
    run *cmd, **args
  rescue
    puts ">> fail to run '#{cmd.join(" ")}'... moving on!"
  end
end

def run(*cmd, **args)
  full_args = process_args(args)

  cmd.push args[:action]

  sh "#{cmd.join(" ")} #{full_args.join(" ")}"
end

def run_multi(full_cmd = "")
  sh full_cmd.gsub(/\s+/, " ").strip
end

def process_args(args = {})
  args.reject do |k, v|
    k == :action
  end.map do |k, v|
    if v.class == Array
      v.map do |val|
        "--#{k}='#{val.strip}'"
      end.join " "
    else
      "--#{k}='#{v.strip}'"
    end
  end
end
