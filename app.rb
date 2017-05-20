# frozen_string_literal: true

require 'sinatra'

def secure_digest(str)
  Digest::SHA512.digest str
end
private :secure_digest

BASIC_AUTH_LOGIN    = secure_digest(ENV.fetch('BASIC_AUTH_LOGIN')).freeze
BASIC_AUTH_PASSWORD = secure_digest(ENV.fetch('BASIC_AUTH_PASSWORD')).freeze

use Rack::Auth::Basic, 'Restricted Area' do |login, password|
  Rack::Utils.secure_compare(secure_digest(login), BASIC_AUTH_LOGIN) &&
    Rack::Utils.secure_compare(secure_digest(password), BASIC_AUTH_PASSWORD)
end

get '/' do
  'Form will be here'
end

