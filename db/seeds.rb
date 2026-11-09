# Explicit local setup only; never run seeds automatically on server startup.
raise 'Development seeds are disabled in production' if Rails.env.production?

email = ENV.fetch('SEED_EMAIL', 'developer@example.test').strip.downcase
user = User.find_or_initialize_by(email: email)
if user.new_record?
  password = ENV['SEED_PASSWORD'].to_s
  raise 'Set SEED_PASSWORD to a password of at least 12 characters' if password.length < 12

  user.password = password
  user.save!
end

client = Client.find_or_initialize_by(name: ENV.fetch('SEED_CLIENT_NAME', 'local-development'))
if client.new_record?
  client.description = 'Local development client'
  client.save!
end

puts "Development user #{user.email} and client #{client.name} are ready."
