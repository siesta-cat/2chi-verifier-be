import app
import gleam/http.{Get}
import gleam/json
import gleam/result
import token
import url_provider
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: app.Context) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  case wisp.path_segments(req) {
    ["image"] -> get_image(req, ctx)
    ["image", "review"] -> todo
    _ -> wisp.not_found()
  }
}

fn get_image(req: Request, ctx: app.Context) -> Response {
  use <- wisp.require_method(req, Get)

  case fetch_image(ctx) {
    Ok(resp) -> resp
    Error(msg) -> panic as msg
  }
}

fn fetch_image(ctx: app.Context) -> Result(Response, String) {
  use url <- result.try(url_provider.next(ctx.url_provider))
  let token = token.generate(ctx.token_secret, url)
  let json =
    json.object([#("url", json.string(url)), #("token", json.string(token))])
    |> json.to_string_tree

  Ok(wisp.json_response(json, 200))
}
