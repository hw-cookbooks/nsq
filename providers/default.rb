use_inline_resources if respond_to?(:use_inline_resources)

NSQ_CONFIG_FILE_SUPPORT = %w(nsqadmin nsqd nsqlookupd)

def load_current_resource

  @config_dir = ::File.join(
    node[:nsq][:setup][:directory][:config],
    new_resource.app,
    new_resource.name
  )

  @service_name = "#{new_resource.app}-#{new_resource.name}"

  unless(new_resource.run_as)
    new_resource.run_as node[:nsq][:setup][:user][:run_as]
  end

  unless(node[:nsq][:enabled])
    node.set[:nsq][:enabled] = []
  end

  new_resource.config Mash.new(new_resource.config)

  if(new_resource.use_config_file.nil?)
    new_resource.use_config_file(
      NSQ_CONFIG_FILE_SUPPORT.include?(
        new_resource.app.to_s
      )
    )
  end

end

action :add do

  config_dir = @config_dir
  service_name = @service_name

  run_context.include_recipe 'nsq::install'

  nsq_user new_resource.run_as do
    only_if{ new_resource.create_user }
  end

  directory config_dir do
    recursive true
  end

  directory new_resource.config.fetch(:data_path, 'nsq<unset>') do
    recursive true
    owner new_resource.run_as
    only_if{ new_resource.config[:data_path] }
  end

  file config = ::File.join(config_dir, 'config') do
    content new_resource.config.map{|k,v| "#{k} = #{v.inspect}" }.join("\n")
    mode 0644
    if(node[:nsq][:enabled].include?(service_name))
      notifies :restart, "service[#{service_name}]"
    end
    only_if{ new_resource.use_config_file }
  end

  if(new_resource.use_config_file)
    options = "-config #{config}"
  else
    options = new_resource.config.map do |k,v|
      k = k.to_s.tr('_', '-')
      ["-#{k}", v.inspect].join('=')
    end.join(' ')
  end

  service_provider = Chef::Provider::Service::Simple
  setup_block = nil
  service_actions = [:enable, :start]

  command = ::File.join(
    node[:nsq][:install][:bindir], new_resource.app
  ) << " #{options}"

  log_file = ::File.join(
    node[:nsq][:setup][:directory][:log],
    @service_name,
    "#{new_resource.app}.log"
  )

  pid_file = ::File.join(
    node[:nsq][:setup][:directory][:pid],
    @service_name,
    "#{new_resource.app}.pid"
  )

  unless(new_resource.init.nil? || new_resource.init == 'initd')
    case new_resource.init
    when 'runit'
      run_context.include_recipe 'runit'
      setup_block = lambda do
        runit_service service_name do
          default_logger true
          run_template_name 'nsq'
          restart_on_update false
          action :enable
          options Mash.new(
            :cmd => command,
            :user => new_resource.run_as
          )
        end
      end
      service_provider = Chef::Provider::Service::Init
      service_actions = :start
    when 'upstart'
      setup_block = lambda do

        directory File.dirname(log_file) do
          recursive true
          owner new_resource.run_as
        end

        template "/etc/init/#{service_name}.conf" do
          cookbook 'nsq'
          source 'nsq.upstart.erb'
          variables Mash.new(
            :app => new_resource.app,
            :name => new_resource.name,
            :user => new_resource.run_as,
            :cmd => command,
            :log => log_file
          )
          if(node[:nsq][:enabled].include?(service_name))
            notifies :restart, "service[#{service_name}]", :immediately
          end
        end
      end
      service_provider = Chef::Provider::Service::Upstart
    else
      setup_block = lamdba do

        directory File.dirname(log_file) do
          recursive true
          owner new_resource.run_as
        end

        directory File.dirname(pid_file) do
          recursive true
          owner new_resource.run_as
        end

        template "/etc/init.d/#{service_name}" do
          cookbook 'nsq'
          mode 0755
          source 'nsq.initd.erb'
          variables Mash.new(
            :cmd => command,
            :app => new_resource.app,
            :name => new_resource.name,
            :pid_file => pid_file,
            :user => new_resource.run_as,
            :log => log_file
          )
          if(node[:nsq][:enabled].include?(service_name))
            notifies :restart, "service[#{service_name}]", :immediately
          end
        end
      end
    end
  end

  if(setup_block)
    service service_name do
      provider service_provider
    end

    setup_block.call

    service service_name do
      action service_actions
    end
  end

end

action :remove do

  config_dir = @config_dir
  service_name = @service_name

  directory config_dir do
    action :delete
    recursive true
  end

  enabled = node[:nsq][:enabled].dup
  enabled.delete(service_name)
  node.set[:nsq][:enabled] = enabled

end
