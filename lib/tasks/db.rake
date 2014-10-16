# lib/tasks/db.rake
namespace :db do

  desc "Dumps the database to db/APP_NAME.dump"
  task :dump => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      return "database not found" if db.blank?
      cmd = "pg_dump "
      unless host.blank?
        cmd += "--host #{host} "
      end
      unless user.blank?
        cmd += "--username #{user} "
      end
      cmd += "--verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/"
      cmd += app.blank? ? "#db_dump_#{DateTime.now.strftime('%y%m%d_%H%M')}.dump" : "#{app}_#{DateTime.now.strftime('%y%m%d_%H%M')}.dump"
      # cmd = "pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}_#{DateTime.now.strftime('%y%m%d_%H%M')}.dump"
    end
    puts cmd
    exec cmd
  end

  desc "Restores the database dump at db/APP_NAME.dump."
  task :restore => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{app}.dump"
    end
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    puts cmd
    exec cmd
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
    ActiveRecord::Base.connection_config[:host],
    # `hostname`.gsub('\n', ''),
    ActiveRecord::Base.connection_config[:database],
    ActiveRecord::Base.connection_config[:username]
  end

end