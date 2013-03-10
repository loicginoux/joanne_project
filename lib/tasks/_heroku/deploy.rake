# List of environments and their heroku git remotes
  ENVIRONMENTS = {
    :staging => "staging", #'calm-gorge-1213'
    :production => "heroku" #'quiet-summer-5721'
  }

  HEROKU_APP = {
    :staging => 'calm-gorge-1213',
    :production => 'quiet-summer-5721'
  }

  namespace :deploy do
    ENVIRONMENTS.keys.each do |env|
      desc "Deploy to #{env}"
      task env, [:commitMessage] => :environment do |t, args|
        args.with_defaults(:commitMessage => "commit")
        current_branch = `git branch | grep ^* | awk '{ print $2 }'`.strip
        puts "skype :#{args[skipAssets]}"

        Rake::Task['deploy:before_deploy'].invoke(env, current_branch, args[:commitMessage])
        Rake::Task['deploy:update_code'].invoke(env, current_branch, args[:commitMessage])
        Rake::Task['deploy:after_deploy'].invoke(env, current_branch, args[:commitMessage])
      end
    end

    task :before_deploy, [:env, :branch, :commitMessage] => :environment do |t, args|
      puts "Deploying #{args[:branch]} to #{args[:env]}"
    end

    task :after_deploy, [:env, :branch, :commitMessage] => :environment do |t, args|
      puts "Deployment complete: #{args[:branch]} to #{args[:env]}"
    end

    task :update_code, [:env, :branch, :commitMessage] => :environment do |t, args|
      FileUtils.cd Rails.root do
        puts "Updating #{ENVIRONMENTS[args[:env]]} with branch #{args[:branch]}"
        `git push #{ENVIRONMENTS[args[:env]]} #{args[:branch]}:master`
      end
    end
  end