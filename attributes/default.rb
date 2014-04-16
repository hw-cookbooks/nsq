default[:nsq][:install][:base_remote] = 'https://s3.amazonaws.com/bitly-downloads/nsq'
default[:nsq][:install][:go_version] = '1.2'
default[:nsq][:install][:platform] = node.platform?('mac_os_x') ? 'darwin' : 'linux'
default[:nsq][:install][:machine] = 'amd64' # really should be hardcoded but what the hell
default[:nsq][:install][:extension] = '.tar.gz'
default[:nsq][:install][:version] = '0.2.27'
default[:nsq][:install][:storage_directory] = '/usr/src'
default[:nsq][:install][:bindir] = '/usr/local/bin'
default[:nsq][:install][:method] = 'tarball'

default[:nsq][:setup][:directory][:config] = '/etc/nsq'
default[:nsq][:setup][:directory][:log] = '/var/log/nsq'
default[:nsq][:setup][:directory][:pid] = '/var/run/nsq'
default[:nsq][:setup][:user][:run_as] = 'nsq'
default[:nsq][:setup][:user][:base_directory] = '/var/lib/data'

default[:nsq][:default_config] = {}
default[:nsq][:instances] = {}
