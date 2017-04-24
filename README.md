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

```ruby
task :database => 'environment:staging:database' do
  database.query 'UPDATE settings SET value="http://dev-project.local" WHERE name="url"'
  remote_file_name = database.dump # dumps the database to the returned file
  database.load_dump(remote_file_name) # loads an sql dump
  local_filename = database.download_dump # downloads an sql dump to your machine
```

## Syncing

If you configured more than one database on different environments, fulmar will
create task to sync these databases via mysql_dump. This allows you to update a
staging or preview database with the data from the production system.

```
fulmar database:update:preview:from_live
```

The task to copy data *to* the live database is hidden (it has no description).


## Limitations

You can not use SELECT or other queries that return data.

Query cannot contain single quotes at the moment. This is due to the queries beeing passed to the mysql shell client
and escaping does not work correctly then. So you should avoid running complex queries with this fulmar plugin. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CORE4/fulmar-plugin-mariadb.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).




### Database access

Within a task you can access and update databases (mariadb/mysql at the time of writing). Remote databases do not need
to be accessible directly since fulmar uses an ssh tunnel to connect to the host first. So the database host is often
just "localhost" (the default value). You can specify a different host if you database server is on another host, which
is the case on most simple web spaces.

The field "maria:database" is required. The other fields are optional. You can use the file `.my.cnf`
to specify the password only on the host itself and not have it in your deployment code.

```yaml
environments:
  staging:
    database:
      host: project-staging
      type: maria
      mariadb:
        database: db_name
        user: root
        password:
        port: 3306
        host: localhost
        encoding: utf-8
```


end

You can query the database like this:



You can use all features of the mysql2 gem via `database.client`.



