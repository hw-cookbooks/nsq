# NSQ Cookbook

Chef cookbook for installing and configuring NSQ applications

## Usage

### Attribute driven

```ruby
# roles/msg-bus.rb

name 'msg-bus'

default_attributes(
  :nsq => {
    :instances => {
      :msg_bus => {
        :app => 'nsqd',
        :config => {
          :data_path => '/var/lib/data/msg-bus'
        }
      }
    }
  }
)
```

### LWRP

```ruby
nsq 'msg_bus' do
  app 'nsqd'
  config {:data_path => '/var/lib/data/msg-bus'}
end
```

## Infos

* Repository: https://github.com/hw-cookbooks/nsq
