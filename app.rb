# frozen_string_literal: true

require 'sinatra'
require 'telegram/bot'

BOT_TOKEN   = ENV.fetch('TELEGRAM_BOT_API_TOKEN').freeze
BOT_CHAT_ID = ENV.fetch('TELEGRAM_BOT_API_CHAT_ID', '@test_temp_chnl_42').freeze
BOT_MSG_FORMAT = 'HTML'

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

set :protection, except: :frame_options

get '/' do
  erb :telegram_form
end

post '/channel' do
  msg_title = params['title'].to_s.strip
  msg_body  = params['text'].to_s.strip
  msg_link  = params['ref_url'].to_s.strip

  if msg_body.empty? || msg_link.empty?
    halt 400, 'Текст и ссылка обязательны к заполнению.'
  end

  chat_msg = String.new
  unless msg_title.empty?
    chat_msg << "<b>#{Rack::Utils.escape_html msg_title}</b>\n\n"
  end
  chat_msg << msg_body << "\n\n#{msg_link}"

  status = false
  Telegram::Bot::Client.run(BOT_TOKEN) do |bot|
    result = bot.api.send_message(
        chat_id:    BOT_CHAT_ID,
        text:       chat_msg,
        parse_mode: BOT_MSG_FORMAT
    )
    status = result['ok']
  end
  
  status ? 'Success' : 'Failed, sorry'
end
