require 'fulmar/domain/model/configuration'
require 'fulmar/plugin/mariadb/database'
require_relative 'fake_shell'

FULMAR_TEST_CONFIG = {
  environments: {
    test: {
      database: {
        hostname: 'remote-host',
        mariadb: {
          user: 'testuser',
          password: 'testpassword',
          host: 'database-host',
          database: 'test_database'
        }
      }
    }
  },
  plugins: [ 'mariadb' ]
}

describe Fulmar::Plugin::MariaDB::Database do
  before :each do
    # Make all methods public for testing
    Fulmar::Plugin::MariaDB::Database.send(:public, *Fulmar::Plugin::MariaDB::Database.protected_instance_methods)

    # Make a deep copy of the hash so we have a fresh copy for every test
    config_copy = Marshal.load(Marshal.dump(FULMAR_TEST_CONFIG))
    @config = Fulmar::Domain::Model::Configuration.new(config_copy, '/tmp')
    @config.set(:test, :database)
    remote_shell = FakeShell.new('/fake/remote', 'fake-host')
    local_shell = FakeShell.new('/fake/local', 'localhost')
    @database = Fulmar::Plugin::MariaDB::Database.new(@config, remote_shell, local_shell)
  end

  describe '#instantiation' do
    it 'should take a shell to use for all mysql calls' do
      expect(@database.shell.host).to eql('fake-host')
    end

    it 'should take a second, local shell for some copy commands' do
      expect(@database.local_shell.host).to eql('localhost')
    end
  end

  describe '#create' do
    it 'should run a query to create a new database' do
      @database.create('foobar')
      expect(@database.shell.last_command).to match(/CREATE DATABASE/)
      expect(@database.shell.last_command).to include('foobar')
    end

    it 'should add a user' do
      @database.create('foobar', 'foouser', 'barpass')
      expect(@database.shell.last_command).to match(/GRANT ALL/)
      expect(@database.shell.last_command).to include('foouser')
      expect(@database.shell.last_command).to include('barpass')
      expect(@database.shell.last_command).to include('localhost')
    end

    it 'should set a hostname if requested' do
      @database.create('foobar', 'foouser', 'barpass', '%')
      expect(@database.shell.last_command).to match(/@["']?%["']?/)
    end
  end

  describe '#ignore_tables' do
    it 'should return a single command line paramater for a string' do
      @config[:mariadb][:ignore_tables] = 'crappy_stuff'
      expect(@database.ignore_tables).to eql('--ignore-table=test_database.crappy_stuff')
    end

    it 'should return a multiple command line paramaters for an array' do
      @config[:mariadb][:ignore_tables] = %w(foo bar baz)
      params = '--ignore-table=test_database.foo --ignore-table=test_database.bar --ignore-table=test_database.baz'
      expect(@database.ignore_tables).to eql(params)
    end
  end

  describe '#diffable' do
    it 'should return a command parameter when the option is set' do
      @config[:mariadb][:diffable_dump] = true
      expect(@database.diffable).to_not be_empty
    end

    it 'should return an empty string when nothing is set' do
      expect(@database.diffable).to be_empty
    end
  end

  describe '#backup_filename' do
    it 'should return a filename containing the database name' do
      expect(@database.backup_filename).to include(@config[:mariadb][:database])
      expect(@database.backup_filename).to match(/\.sql$/)
    end
  end

  describe '#query' do
    it 'should give the query to the shell' do
      test_query = 'SELECT 1+2'
      @database.query(test_query)
      expect(@database.shell.last_command).to include(test_query)
    end
  end

  describe '#dump' do
    it 'should run myqsldump' do
      @database.dump
      expect(@database.shell.last_command).to include('mysqldump')
    end

    it 'should dump into a given filename' do
      @database.dump('my_test_file.sql')
      expect(@database.shell.last_command).to include('my_test_file.sql')
    end
  end

  describe '#load_dump' do
    it 'should run mysql' do
      @database.load_dump('test_file.sql')
      expect(@database.shell.last_command).to include('mysql ')
    end

    it 'should load the given sql file' do
      @database.load_dump('test_file.sql')
      expect(@database.shell.last_command).to include('test_file.sql')
    end
  end

  describe '#download_dump' do
    it 'should dump into a given file' do
      @database.download_dump('/tmp/foo.sql')
      expect(@database.local_shell.last_command).to include('/tmp/foo.sql')
    end

    it 'should run ssh, mysqldump, and gzip' do
      @database.download_dump
      expect(@database.local_shell.last_command).to include('ssh')
      expect(@database.local_shell.last_command).to include('mysqldump')
      expect(@database.local_shell.last_command).to include('gzip')
    end
  end
end
