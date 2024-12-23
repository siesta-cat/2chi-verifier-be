import gleam/json
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use _req <- wisp.handle_head(req)
  let object =
    json.object([
      #("url", json.string("https://siesta.cat")),
      #("token", json.string("chicatoken")),
    ])
  let tree = json.to_string_builder(object)

  wisp.json_response(tree, 200)
}
