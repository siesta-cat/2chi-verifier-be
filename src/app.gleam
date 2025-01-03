import url_provider

pub type Context {
  Context(url_provider: url_provider.UrlProvider, token_secret: BitArray)
}
