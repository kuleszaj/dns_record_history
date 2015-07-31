require './lib/dns_records'
require 'resolv'

config_file = File.join(@project_root, 'config', 'config.yml')

if File.exist?(config_file)
  config = YAML.load_file(config_file)
else
  abort('You have not populated the configuration file.')
end

namespace :dns do
  desc 'For all domains and record types, record the current DNS records.'
  task :track_records do
    config.each do |item|
      dns_records = DNSRecords.new(item['fqdn'], item['record_types'].collect { |type| Object.const_get(type) })
      dns_records.retrieve_records
      dns_records.store_records_if_different
    end
  end
end
