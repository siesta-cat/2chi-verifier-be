import api/gelbooru
import app
import config
import gleam/json
import gleam/set
import gleeunit/should
import router
import token
import url_provider
import wisp
import wisp/testing

pub fn post_image_review_accepted_test() {
  let #(ctx, body) = post_review_context_and_body(is_accepted: True)

  let response =
    router.handle_request(
      testing.post(
        "/image/review",
        [#("content-type", "application/json")],
        body,
      ),
      ctx,
    )

  response.status |> should.equal(201)
}

pub fn post_image_review_not_accepted_test() {
  let #(ctx, body) = post_review_context_and_body(is_accepted: False)
  let response =
    router.handle_request(
      testing.post(
        "/image/review",
        [#("content-type", "application/json")],
        body,
      ),
      ctx,
    )

  response.status |> should.equal(201)
}

fn post_review_context_and_body(
  is_accepted is_accepted: Bool,
) -> #(app.Context, String) {
  let assert Ok(cfg) = config.load_from_env()
  let ctx =
    app.Context(
      url_provider: url_provider.new(gelbooru.get_images_page, set.new()),
      config: cfg,
    )
  let url = "https://images.com/" <> wisp.random_string(5)
  let body =
    json.to_string(
      json.object([
        #("url", json.string(url)),
        #("token", json.string(token.generate(cfg.token_secret, url))),
        #("is_accepted", json.bool(is_accepted)),
      ]),
    )
  #(ctx, body)
}
