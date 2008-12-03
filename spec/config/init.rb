Merb::Config.use do |c|
  c[:default_cookie_domain] = "resourceful.davidleal.com"
  c[:session_id_key] = "key"
  c[:session_secret_key] = "shhhhhh"
  c[:session_expiry] = Merb::Const::WEEK * 4
  c[:log_auto_flush ] = true
  c[:log_level] = :debug
  c[:log_file]   = File.join(File.dirname(__FILE__), '..', '..', 'log', 'test.log')
end
