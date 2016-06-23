module Fulmar
  module Plugin
    module MariaDB
      module DslHelper
        # Return a mariadb object to query the database or get dumps
        def mariadb
          shell = configuration[:hostname] && configuration[:hostname] != 'localhost' ? remote_shell : local_shell
          storage['mariadb'] ||= Fulmar::Plugin::MariaDB::Database.new configuration, shell, local_shell
        end
      end
    end
  end
end
