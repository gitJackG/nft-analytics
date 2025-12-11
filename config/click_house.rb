ClickHouse.config do |config|
  config.logger = Logger.new(STDOUT)
  config.adapter = :net_http
  config.database = "nft_analytics"
  config.url = "http://localhost:8123"
  config.timeout = 60
  config.open_timeout = 3
  config.ssl_verify = false
  # set to true to symbolize keys for SELECT and INSERT statements (type casting)
  config.symbolize_keys = false
  config.headers = {}

  # # or provide connection options separately
  # config.scheme = 'http'
  # config.host = 'localhost'
  # config.port = 'port'

  # # if you use HTTP basic Auth
  # config.username = 'user'
  # config.password = 'password'

  # # if you want to add settings to all queries
  # config.global_params = { mutations_sync: 1 }

  # choose a ruby JSON parser (default one)
  config.json_parser = ClickHouse::Middleware::ParseJson
  # # or Oj parser
  # config.json_parser = ClickHouse::Middleware::ParseJsonOj

  # JSON.dump (default one)
  config.json_serializer = ClickHouse::Serializer::JsonSerializer
  # # or Oj.dump
  # config.json_serializer = ClickHouse::Serializer::JsonOjSerializer
end
