import app
import given
import gleam/dynamic/decode
import gleam/http
import gleam/json
import token
import url_provider
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: app.Context) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  case wisp.path_segments(req) {
    ["image"] -> get_image(req, ctx)
    ["image", "review"] -> post_image_review(req, ctx)
    _ -> wisp.not_found()
  }
}

fn get_image(req: Request, ctx: app.Context) -> Response {
  use <- wisp.require_method(req, http.Get)

  use url <- given.ok_in(
    url_provider.next(ctx.url_provider),
    else_return: fn(msg) {
      wisp.log_error(msg)
      wisp.internal_server_error()
    },
  )

  let token = token.generate(ctx.token_secret, url)
  let json =
    json.object([#("url", json.string(url)), #("token", json.string(token))])
    |> json.to_string_tree

  wisp.json_response(json, 200)
}

fn post_image_review(req: Request, ctx: app.Context) -> Response {
  use <- wisp.require_method(req, http.Post)
  use json <- wisp.require_json(req)

  let decoder = {
    use url <- decode.field("url", decode.string)
    use token <- decode.field("token", decode.string)
    use is_accepted <- decode.field("is_accepted", decode.bool)
    decode.success(#(url, token, is_accepted))
  }

  use #(_url, token, _is_accepted) <- given.ok_in(
    decode.run(json, decoder),
    else_return: fn(_) { wisp.bad_request() },
  )

  use <- given.not_given(token.validate(ctx.token_secret, token), return: fn() {
    wisp.bad_request()
  })

  wisp.created()
}
