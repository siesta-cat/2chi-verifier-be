import cache
import gleam/http.{Get}
import gleam/json
import gleam/result
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, cache: cache.ImageCache) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  case wisp.path_segments(req) {
    ["image"] -> get_image(req, cache)
    ["image", "review"] -> todo
    _ -> wisp.not_found()
  }
}

fn get_image(req: Request, cache: cache.ImageCache) -> Response {
  use <- wisp.require_method(req, Get)

  case fetch_image(cache) {
    Ok(resp) -> resp
    Error(msg) -> panic as msg
  }
}

fn fetch_image(cache: cache.ImageCache) -> Result(Response, String) {
  use image <- result.try(cache.next(cache))

  let json =
    json.object([
      #("url", json.string(image)),
      #("token", json.string("chicatoken")),
    ])
    |> json.to_string_builder

  Ok(wisp.json_response(json, 200))
}
