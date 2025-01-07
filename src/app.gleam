import url_provider

pub type Context {
  Context(
    url_provider: url_provider.UrlProvider,
    auth_token: String,
    config: Config,
  )
}

pub type Config {
  Config(
    bot_api_base_url: String,
    port: Int,
    api_app_name: String,
    api_secret: String,
    token_secret: BitArray,
  )
}
