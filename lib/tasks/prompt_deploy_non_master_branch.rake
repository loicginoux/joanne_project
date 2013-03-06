namespace :deploy do
    task :before_deploy, [:env, :branch, :commitMessage] => :environment do |t, args|
      # Ensure the user wants to deploy a non-master branch to production

      if args[:env] == :production && args[:branch] != 'master'
        print "Continue deploying '#{args[:branch]}' to production? (y/n) " and STDOUT.flush
        char = $stdin.getc
        if char != ?y && char != ?Y
         puts "Deploy aborted"
         exit
        end
      end
    end
  end