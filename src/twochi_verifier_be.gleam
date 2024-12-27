import api/bot
import api/gelbooru
import cache
import config
import gleam/erlang/process
import gleam/set
import mist
import router
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let bot_urls = case bot.get_all(config.AppConfig("http://cottonee:30000")) {
    Ok(urls) -> set.from_list(urls)
    Error(msg) -> panic as msg
  }

  let cache = cache.new(gelbooru.get_images_page, bot_urls)

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request(_, cache), secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}
