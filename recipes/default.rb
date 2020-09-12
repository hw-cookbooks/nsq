# Iterate and generate any attribute based resources

node['nsq']['instances'].each do |name, args|
  nsq name do
    args.each do |attr_name, attr_value|
      send(attr_name, lazy { attr_value })
    end
  end
end
