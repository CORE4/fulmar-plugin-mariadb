module Fulmar
  module Plugin
    module MariaDB
      module DslHelper
        # Return a mariadb object to query the database or get dumps
        def mariadb
          shell = config[:hostname] && config[:hostname] != 'localhost' ? remote_shell : local_shell
          storage['mariadb'] ||= Fulmar::Plugin::MariaDB::Database.new config, shell, local_shell
        end
      end
    end
  end
end
