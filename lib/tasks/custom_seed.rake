# Dynamically define seed tasks based on the files in `db/seeds/*.rb`
# e.g. bundle exec rails db:seed:production
#      bundle exec rails db:seed:test
namespace :db do
  namespace :seed do
    Rails.root.glob("db/seeds/*.rb").each do |filename|
      task_name = File.basename(filename, ".rb")
      desc "Seed #{task_name}, based on the file with the same name in `db/seeds/*.rb`"
      task task_name.to_sym => :environment do
        load(filename) if File.exist?(filename)
      end
    end
  end
end
