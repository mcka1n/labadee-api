# Adopt explicitly tested behavior rather than future ODM defaults implicitly.
Mongoid.configure do |config|
  config.load_defaults '9.1'
end

# Driver DEBUG command logs contain raw selectors/documents and bypass Rails'
# parameter filtering. Keep diagnostic warnings without recording credentials.
Rails.application.config.after_initialize do
  database_logger = ActiveSupport::Logger.new($stdout)
  database_logger.level = Logger::WARN
  Mongoid.logger = database_logger
  Mongo::Logger.logger = database_logger
end
