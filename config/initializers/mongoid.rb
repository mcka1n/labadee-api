# Adopt explicitly tested behavior rather than future ODM defaults implicitly.
Mongoid.configure do |config|
  config.load_defaults '9.1'
end
