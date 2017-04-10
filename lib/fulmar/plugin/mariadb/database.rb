require 'fulmar/shell'

module Fulmar
  module Plugin
    module MariaDB
      # Provides basic methods common to all database services
      class Database
        attr_reader :shell, :local_shell

        DEFAULT_CONFIG = {
          mariadb: {
            host: '127.0.0.1',
            port: 3306,
            user: 'root',
            password: '',
            encoding: 'utf8',
            ignore_tables: [],
            diffable_dump: false,
            dump_path: '/tmp'
          }
        }

        def initialize(config, shell = initialize_shell, local_shell = nil)
          @config = config
          @config.merge DEFAULT_CONFIG
          @shell = shell
          @local_shell = local_shell || Fulmar::Shell.new(@config[:mariadb][:dump_path])
          @local_shell.debug = true if config[:debug] # do not deactivate debug mode is shell set it explicitly
          config_test
        end

        def create(name, user = nil, password = nil, host = 'localhost')
          query "CREATE DATABASE IF NOT EXISTS `#{name}`"
          if user
            password_sql = password ? " IDENTIFIED BY \"#{password}\"" : ''
            query "GRANT ALL ON `#{name}`.* TO #{user}@#{host}#{password_sql}"
          end
        end

        def query(sql_query)
          if sql_query.include?('\'')
            fail 'This fulmar plugin currently does no support queries with single quotes to the simple '\
                 " quoting in fulmar shell. Query was: #{sql_query}"
          end

          @shell.run "#{command('mysql')} -D '#{@config[:mariadb][:database]}' -e '#{sql_query}'"
        end

        # Add parameters like host, user, and password to the base command like mysql or mysqldump
        def command(binary)
          command = binary
          command << " -h #{@config[:mariadb][:host]}" unless @config[:mariadb][:host].blank?
          command << " -u #{@config[:mariadb][:user]}" unless @config[:mariadb][:user].blank?
          command << " --password='#{@config[:mariadb][:password]}'" unless @config[:mariadb][:password].blank?
          command
        end

        def dump(filename = backup_filename)
          filename = "#{@config[:mariadb][:dump_path]}/#{filename}" unless filename[0, 1] == '/'
          @shell.run "#{dump_command} -r \"#{filename}\""
          filename
        end

        def load_dump(dump_file, database = @config[:mariadb][:database])
          @shell.run "#{command('mysql')} -D #{database} < #{dump_file}"
        end

        def download_dump(filename = "#{backup_filename}.gz")
          local_path = filename[0, 1] == '/' ? filename : "#{@config[:mariadb][:dump_path]}/#{filename}"
          remote_command = "#{dump_command} | gzip"
          @local_shell.run "ssh #{@config.ssh_user_and_host} \"#{remote_command}\" > #{local_path}"
          local_path
        end

        protected

        def dump_command
          "#{command('mysqldump')} #{@config[:mariadb][:database]} --single-transaction #{diffable} #{ignore_tables}"
        end

        # Return mysql command line options to ignore specific tables
        def ignore_tables
          @config[:mariadb][:ignore_tables] = [*@config[:mariadb][:ignore_tables]]
          @config[:mariadb][:ignore_tables].map do |table|
            "--ignore-table=#{@config[:mariadb][:database]}.#{table}"
          end.join(' ')
        end

        # Return the mysql configuration options to make a dump diffable
        def diffable
          @config[:mariadb][:diffable_dump] ? '--skip-comments --skip-extended-insert ' : ''
        end

        # Test configuration
        def config_test
          fail 'Configuration option "database" missing.' unless @config[:mariadb][:database]
        end

        # Builds the filename for a new database backup file
        # NOTE: The file might already exist, for example if this is run at the same
        # time from to different clients. I won't handle this as it is unlikely and
        # would result in more I/O
        def backup_filename
          "#{@config[:mariadb][:database]}_#{Time.now.strftime('%Y-%m-%dT%H%M%S')}.sql"
        end

        def initialize_shell
          @shell = Fulmar::Shell.new(@config[:mariadb][:dump_path], @config.ssh_user_and_host)
          @shell.debug = true if @config[:debug]
          @shell.strict = true
        end
      end
    end
  end
end
