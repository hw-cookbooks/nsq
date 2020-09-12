require 'uri'

# Build our filename
nsq_remote_path = 'nsq-' <<
                  node['nsq']['install']['version'] << '.' <<
                  node['nsq']['install']['platform'] << '-' <<
                  node['nsq']['install']['machine'] << '.' <<
                  'go' << node['nsq']['install']['go_version'] <<
                  node['nsq']['install']['extension']
nsq_remote_path = File.join(node['nsq']['install']['base_remote'], nsq_remote_path)

nsq_file_name = File.basename(nsq_remote_path)

nsq_local_path = File.join(
  node['nsq']['install']['storage_directory'],
  nsq_file_name
)

remote_file nsq_local_path do
  source nsq_remote_path
end

execute "NSQ unpack[#{File.basename(nsq_remote_path)}]" do
  command "tar xvzf #{File.basename(nsq_remote_path)}"
  cwd node['nsq']['install']['storage_directory']
  creates File.join(
    node['nsq']['install']['storage_directory'],
    nsq_file_name.sub(
      /#{Regexp.escape(node["nsq"]["install"]["extension"])}$/, ''
    )
  )
end

directory node['nsq']['install']['bindir'] do
  recursive true
end

execute "NSQ bin install[v#{node['nsq']['install']['version']}]" do
  command "cp bin/* #{node['nsq']['install']['bindir']}"
  not_if "#{File.join(node['nsq']['install']['bindir'], 'nsqd')} -version " <<
         "| grep 'v#{node['nsq']['install']['version']}' | grep 'go#{node['nsq']['install']['go_version']}'"
  cwd File.join(
    node['nsq']['install']['storage_directory'],
    nsq_file_name.sub(
      /#{Regexp.escape(node["nsq"]["install"]["extension"])}$/, ''
    )
  )
end
