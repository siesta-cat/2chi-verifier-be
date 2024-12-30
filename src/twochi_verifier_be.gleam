import api/bot
import api/gelbooru
import config
import gleam/erlang/process
import gleam/set
import mist
import router
import url_provider
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  let assert Ok(config) = config.load_from_env()
  let provider = setup_provider(config)

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request(_, provider), secret_key_base)
    |> mist.new
    |> mist.port(config.port)
    |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}

fn setup_provider(config: config.AppConfig) -> url_provider.UrlProvider {
  let assert Ok(filter_urls) = bot.get_all(config)

  url_provider.new(gelbooru.get_images_page, set.from_list(filter_urls))
}
