# List of environments and their heroku git remotes

# bundle exec rake deploy:production
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
      puts "Pushing #{args[:branch]} to github"
      if args[:env] == "production"
        `git push -f origin #{args[:branch]}`
      end
    end

    task :update_code, [:env, :branch, :commitMessage] => :environment do |t, args|
      FileUtils.cd Rails.root do
        puts "Updating #{ENVIRONMENTS[args[:env]]} with branch #{args[:branch]}"
        Bundler.with_clean_env { p `heroku maintenance:on --app #{HEROKU_APP[args[:env]]}` }
        `git push -f #{ENVIRONMENTS[args[:env]]} #{args[:branch]}:master`
        Bundler.with_clean_env { p `heroku run rake cache:flush  --app #{HEROKU_APP[args[:env]]}` }
        Bundler.with_clean_env { p `heroku maintenance:off --app #{HEROKU_APP[args[:env]]}` }
      end
    end
  end