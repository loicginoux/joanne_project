namespace :db do
  desc 'Drop, create, migrate, and seed a database'
  task :reload => :environment do
    input = ''
    STDOUT.puts "Drop and recreate database? y[es] or n[o]"
    input = STDIN.gets.chomp
    if input == "y"
      puts "Executing tasks..."
      Rake::Task["db:drop"].execute
      Rake::Task["db:create"].execute
      Rake::Task["db:migrate"].execute
      Rake::Task["db:test:prepare"].execute
      Rake::Task['db:seed'].execute
    else
      puts "Aborting tasks..."
    end
  end
  desc 'Drop, create, migrate, and seed development and test databases'
  namespace :reload do
    task :all do
      ['development','test'].each do |env|
        Rails.env = env
        puts "=== Starting #{Rails.env} reload ===\n\n"
        Rake::Task['db:reload'].reenable
        Rake::Task['db:reload'].invoke
        puts "=== Finishing #{Rails.env} reload ===\n\n"
      end
    end
  end
end
