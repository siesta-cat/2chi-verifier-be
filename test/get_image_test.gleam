import api/gelbooru
import gleam/dynamic
import gleam/json
import gleam/result
import gleam/set
import gleam/uri
import gleeunit/should
import router
import url_provider
import wisp/testing

pub fn get_image_gives_status_200_test() {
  let provider = url_provider.new(gelbooru.get_images_page, set.new())

  let response = router.handle_request(testing.get("/image", []), provider)

  response.status |> should.equal(200)
}

pub fn get_image_gives_correct_json_response_test() {
  let provider = url_provider.new(gelbooru.get_images_page, set.new())

  let json =
    router.handle_request(testing.get("/image", []), provider)
    |> testing.string_body()

  let url =
    json.decode(json, dynamic.field("url", dynamic.string))
    |> result.replace_error(Nil)
    |> result.map(uri.parse)
    |> result.flatten

  url |> should.be_ok()
}
