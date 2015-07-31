# encoding: utf-8
require 'pg'
require 'yaml'

# Manage connection to Postgres
module Postgres
  @psql = nil

  def self.connection
    @psql ||= create_psql_connection
  end

  private

  def self.create_psql_connection
    if ENV['DATABASE_URL']
      conn = PG.connect(ENV['DATABASE_URL'])
    else
      host = ENV['PSQL_HOST'] || 'localhost'
      port = ENV['PSQL_PORT'] || 5432
      password = ENV['PSQL_PASSWORD'] || nil
      dbname = ENV['PSQL_DATABASE'] || nil
      conn = PG.connect(host: host, port: port, password: password, dbname: dbname)
    end
    conn.prepare('insert', 'INSERT INTO records (fqdn, datetime, record_type, record) VALUES ($1, $2, $3, $4)')
    conn.prepare('select', 'SELECT record FROM records r WHERE r.fqdn = $1 AND r.record_type = $2 ORDER BY r.datetime DESC LIMIT 1')
    conn
  end
end
