require 'resolv'
require 'yaml'
require './lib/postgres'

# Track a DNS record
class DNSRecords
  attr_accessor :fqdn, :record_types, :records

  def initialize(fqdn, record_types = [Resolv::DNS::Resource::IN::A, Resolv::DNS::Resource::IN::MX])
    @fqdn = fqdn
    @record_types = record_types
    @resolver = Resolv::DNS.new
    @records = {}
    @conn = Postgres.connection
  end

  def retrieve_records
    record_types.each do |record_type|
      records[record_type] = @resolver.getresources(fqdn, record_type)
    end
    records
  end

  def store_records
    records.each_pair do |record_type, record|
      @conn.exec_prepared('insert', [@fqdn, Time.now, record_type.to_yaml, record.to_yaml])
    end
  end

  def store_records_if_different
    records.each_pair do |record_type, record|
      @conn.exec_prepared('select', [@fqdn, record_type.to_yaml]) do |result|
        result.each do |row|
          result_record = YAML.load(row['record'])
          @conn.exec_prepared('insert', [@fqdn, Time.now, record_type.to_yaml, record.to_yaml]) unless records_equal?(record, result_record)
        end
        @conn.exec_prepared('insert', [@fqdn, Time.now, record_type.to_yaml, record.to_yaml]) if result.ntuples == 0
      end
    end
  end

  private

  def records_equal?(a, b)
    a = sort_records(a)
    b = sort_records(b)
    a.zip(b).each do |record_a, record_b|
      instance_variables = record_a.instance_variables - [:@ttl]
      instance_variables.each do |variable|
        return false if record_a.instance_variable_get(variable) != record_b.instance_variable_get(variable)
      end
    end
    true
  end

  def sort_records(a)
    instance_variables = a.first.instance_variables - [:@ttl]
    a.sort_by do |entry|
      instance_variables.collect { |variable| entry.instance_variable_get(variable).to_s }
    end
  end
end
