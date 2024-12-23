import gleam/json
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use _req <- wisp.handle_head(req)
  let json =
    json.object([
      #("url", json.string("https://siesta.cat")),
      #("token", json.string("chicatoken")),
    ])
    |> json.to_string_builder

  wisp.json_response(json, 200)
}
