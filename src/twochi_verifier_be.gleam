import api/gelbooru
import cache
import gleam/erlang/process
import mist
import router
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let cache = cache.new(gelbooru.get_images_page)

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request(_, cache), secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}
