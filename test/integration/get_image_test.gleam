import api/gelbooru
import app
import gleam/dynamic
import gleam/io
import gleam/json
import gleam/result
import gleam/set
import gleam/uri
import gleeunit/should
import router
import token
import url_provider
import wisp/testing

pub fn get_image_response_test() {
  let token_secret = <<"secret">>
  let ctx =
    app.Context(
      url_provider: url_provider.new(gelbooru.get_images_page, set.new()),
      token_secret:,
    )

  let response = router.handle_request(testing.get("/image", []), ctx)
  let json = response |> testing.string_body()
  let url =
    json.decode(json, dynamic.field("url", dynamic.string))
    |> result.replace_error(Nil)
    |> result.map(uri.parse)
    |> result.flatten
  let token = json.decode(json, dynamic.field("token", dynamic.string))

  response.status |> should.equal(200)
  url |> should.be_ok()
  token |> should.be_ok()
  let assert Ok(token) = token
  token.validate(token_secret, token) |> should.be_true
}
