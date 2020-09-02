NSQ_APPS = %w(nsqadmin nsqd nsqlookupd nsq_pubsub nsq_stat nsq_tail nsq_to_file nsq_to_http nsq_to_nsq).freeze
NSQ_INITS = %w(upstart runit initd).freeze

actions :add, :remove
default_action :add

attribute :app, equal_to: NSQ_APPS, required: true
attribute :run_as, kind_of: String
attribute :create_user, kind_of: [TrueClass, FalseClass], default: true
attribute :config, kind_of: Hash, required: true
attribute :use_config_file, kind_of: [TrueClass, FalseClass]
attribute :init, equal_to: NSQ_INITS, default: 'runit'
