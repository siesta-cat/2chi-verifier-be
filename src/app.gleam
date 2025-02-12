import url_provider

pub type Context {
  Context(url_provider: url_provider.UrlProvider, config: Config)
}

pub type Config {
  Config(bot_api_base_url: String, port: Int, token_secret: BitArray)
}
