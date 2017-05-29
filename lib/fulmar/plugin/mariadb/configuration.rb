require 'fulmar/plugin/mariadb/version'
require 'fulmar/plugin/mariadb/dsl_helper'
require 'fulmar/plugin/mariadb/database'

module Fulmar
  module Plugin
    module MariaDB
      class Configuration
        def initialize(config)
          @config = config
        end

        def test_files
          ["#{File.dirname(__FILE__)}/config_tests/mariadb.rb"]
        end

        def rake_files
          Dir.glob(File.dirname(__FILE__)+'/rake/*.rake')
        end
      end
    end
  end
end
