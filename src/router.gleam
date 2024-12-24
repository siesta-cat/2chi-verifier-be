import gleam/http.{Get}
import gleam/json
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  case wisp.path_segments(req) {
    ["image"] -> get_image(req)
    ["image", "review"] -> todo
    _ -> wisp.not_found()
  }
}

fn get_image(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  let json =
    json.object([
      #("url", json.string("https://siesta.cat")),
      #("token", json.string("chicatoken")),
    ])
    |> json.to_string_builder

  wisp.json_response(json, 200)
}
