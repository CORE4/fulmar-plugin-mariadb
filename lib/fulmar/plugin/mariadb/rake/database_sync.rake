db_configs = []
config.each do |env, target, data|
  db_configs << [env, target] unless data[:mariadb].nil? || data[:mariadb][:database].nil?
end

# Expects two hashes as parameters each with { :environment, :target, :name } set
# :name is either environment:target or just the environment, if the is only one target
def create_update_task(from, to)
  namespace to[:name] do
    task "from_#{from[:name]}" do
      # Add a bit of security
      if %w(live prod production).include?(to[:environment]) && !ARGV.include?('--force')
        ARGV.reject! { |param| param == '--force' }
        warning 'You are about to update the live database from another source.'
        print 'Are you sure? [y/N] '
        answer = STDIN.gets
        exit if answer.downcase != 'y'
      end

      config.set(from[:environment], from[:target])
      info 'Getting dump...'
      sql_dump = mariadb.download_dump
      if sql_dump == ''
        error 'Cannot create sql dump'
      else
        config.set(to[:environment], to[:target])
        info 'Sending dump...'
        dump_path = config[:mariadb][:dump_path] ||
          Fulmar::Plugin::MariaDB::Database::DEFAULT_CONFIG[:mariadb][:dump_path]
        remote_sql_dump = upload(sql_dump, dump_path)
        mariadb.load_dump(remote_sql_dump)
      end
    end
  end
end

def name(env, target, counts)
  (counts[env] <= 1 || target.nil?) ? env : "#{env}:#{target}"
end

def create_update_tasks(db_configs)
  counts = {}
  db_configs.each do |config|
    counts[config.first] = 0 unless counts[config.first]
    counts[config.first] += 1
  end

  namespace :database do
    db_configs.each do |from_db|
      db_configs.each do |to_db|
        next if from_db == to_db # no need to sync a database to itself
        next if from_db.last != to_db.last # sync only matching target names
        from = {
          environment: from_db.first,
          target: from_db.last,
          name: name(from_db.first, nil, counts)
        }
        to = {
          environment: to_db.first,
          target: to_db.last,
          name: name(to_db.first, to_db.last, counts)
        }
        create_update_task(from, to)
      end
    end
  end
end

if db_configs.any?
  namespace :update do
    create_update_tasks(db_configs) if db_configs.count > 1
  end
end
