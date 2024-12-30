import gleam/http.{Get}
import gleam/json
import gleam/result
import url_provider.{type UrlProvider}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, provider: UrlProvider) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  case wisp.path_segments(req) {
    ["image"] -> get_image(req, provider)
    ["image", "review"] -> todo
    _ -> wisp.not_found()
  }
}

fn get_image(req: Request, provider: UrlProvider) -> Response {
  use <- wisp.require_method(req, Get)

  case fetch_image(provider) {
    Ok(resp) -> resp
    Error(msg) -> panic as msg
  }
}

fn fetch_image(provider: UrlProvider) -> Result(Response, String) {
  use image <- result.try(url_provider.next(provider))

  let json =
    json.object([
      #("url", json.string(image)),
      #("token", json.string("chicatoken")),
    ])
    |> json.to_string_tree

  Ok(wisp.json_response(json, 200))
}
