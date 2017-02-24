# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "#{path}/log/cron.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#every 10.minutes do
#  runner "CheckRadioIsUp.perform_later"
#end
#every '23 11,22 * * *' do
#  command "/home/deploy/certbot-auto renew --quiet --no-self-upgrade && sudo service nginx reload"
#end

job_type :backup, "cd :path/:backup_path && bundle install && :environment_variable=:environment bundle exec backup perform -t :task --config-file ./config.rb :output"

every 1.hours do
  backup 'rails_database', backup_path: 'backup'
end
