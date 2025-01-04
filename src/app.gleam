import url_provider

pub type Context {
  Context(url_provider: url_provider.UrlProvider, token_secret: BitArray)
}

pub type Config {
  Config(bot_api_base_url: String, port: Int, secret: BitArray)
}
