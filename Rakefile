
task :default => :start

namespace :mongodb do
  desc "Start MongoDB for development"
  task :start do
    mkdir_p "db"
    system "mongod --dbpath db/"
  end
end

namespace :app do
	task :start do
		system "ruby ./bot.rb"
	end
end

multitask :start => ["mongodb:start", "app:start"]