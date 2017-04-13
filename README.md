# Fulmar::Plugin::MariaDB

This plugin adds a mariadb method to fulmar tasks. You can only run simple queries without return values to create
a database for example. The main use case for this is to create / load sql dumps.

Please feel free to ask for help.

## Prerequisites

This plugin needs the mysql client to be installed.

## Installation

This plugin will be installable via gem install `fulmar-plugin-mariadb` when it is working. It will need Fulmar 2.
You can also checkout this repo and run `gem build fulmar-plugin-mariadb.gemspec` and
`gem install fulmar-plugin-mariadb*.gem`

## Usage

Add the plugin to your config.yml of the project:

```yaml
plugins:
  mariadb:
```

And add a configuration to either an environment or a host:

```yaml
environments:
  live:
    cms:
      mariadb:
        host: 127.0.0.1
        user: cms_user
        password: password
        database: cms_db_1
```

You can use the [.my.cnf](https://easyengine.io/tutorials/mysql/mycnf-preference/) file if you don't want to put
your database credentials into the config.

## Known limitations

Query cannot contain single quotes at the moment. This is due to the queries beeing passed to the mysql shell client
and escaping does not work correctly then. So you should avoid running complex queries with this fulmar plugin. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CORE4/fulmar-plugin-mariadb.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
