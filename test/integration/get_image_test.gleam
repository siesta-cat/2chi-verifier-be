import api/gelbooru
import app
import gleam/dynamic/decode
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
  let config =
    app.Config(
      bot_api_base_url: "",
      port: 0,
      api_app_name: "",
      api_secret: "",
      token_secret:,
    )
  let ctx =
    app.Context(
      url_provider: url_provider.new(gelbooru.get_images_page, set.new()),
      auth_token: "",
      config:,
    )

  let url_decoder = {
    use field <- decode.field("url", decode.string)
    decode.success(field)
  }

  let token_decoder = {
    use token_decoder <- decode.field("token", decode.string)
    decode.success(token_decoder)
  }

  let response = router.handle_request(testing.get("/image", []), ctx)
  let json = response |> testing.string_body()
  let url =
    json.parse(json, url_decoder)
    |> result.replace_error(Nil)
    |> result.map(uri.parse)
    |> result.flatten
  let token = json.parse(json, token_decoder)

  response.status |> should.equal(200)
  url |> should.be_ok()
  token |> should.be_ok()
  let assert Ok(url) = url
  let assert Ok(token) = token
  token.validate(token_secret, uri.to_string(url), token) |> should.be_true
}
