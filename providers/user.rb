

action :add do
  homedir = ::File.join(
    node['nsq']['setup']['user']['base_directory'],
    new_resource.name
  )

  user new_resource.name do
    system true
    home homedir
  end

  directory homedir do
    recursive true
    owner new_resource.name
  end
end

action :remove do
  user new_resource.name do
    action :remove
  end
end
