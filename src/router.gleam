import api/bot
import app
import cors_builder
import given
import gleam/dynamic/decode
import gleam/http
import gleam/io
import gleam/json
import gleam/string_tree
import token
import url_provider
import wisp.{type Request, type Response}

// TODO: add cors workflow test case
fn cors() {
  cors_builder.new()
  |> cors_builder.allow_all_origins
  |> cors_builder.allow_method(http.Get)
  |> cors_builder.allow_method(http.Post)
}

pub fn handle_request(req: Request, ctx: app.Context) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use req <- cors_builder.wisp_middleware(req, cors())

  case wisp.path_segments(req) {
    ["health"] -> wisp.html_response(string_tree.from_string("Ready"), 200)
    ["image"] -> get_image(req, ctx)
    ["image", "review"] -> post_image_review(req, ctx)
    _ -> wisp.not_found()
  }
}

fn get_image(req: Request, ctx: app.Context) -> Response {
  use <- wisp.require_method(req, http.Get)

  use url <- given.ok(
    in: url_provider.next(ctx.url_provider),
    else_return: fn(msg) {
      wisp.log_error(msg)
      wisp.internal_server_error()
    },
  )

  let token = token.generate(ctx.config.token_secret, url)
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

  use #(url, token, is_accepted) <- given.ok(
    in: decode.run(json, decoder),
    else_return: fn(_) {
      io.println("Could not decode JSON body")
      wisp.log_error("Could not decode JSON body")
      wisp.bad_request()
    },
  )

  use <- given.not(
    the_case: token.validate(ctx.config.token_secret, url, token),
    return: fn() { wisp.bad_request() },
  )

  use _ <- given.ok(
    in: bot.post_image_review(ctx.config.bot_api_base_url, url, is_accepted),
    else_return: fn(msg) {
      wisp.log_error(msg)
      wisp.internal_server_error()
    },
  )

  wisp.created()
}
