import gelbooru
import gleam/json
import gleeunit/should

pub fn gelbooru_decode_test() {
  let urls = ["url1", "url2"]
  let data = gelbooru_test_data(urls)

  gelbooru.decode(data) |> should.equal(Ok(urls))
}

fn gelbooru_test_data(urls: List(String)) -> String {
  json.object([
    #("@attributes", json.object([])),
    #(
      "post",
      json.array(urls, fn(url) {
        json.object([#("file_url", json.string(url))])
      }),
    ),
  ])
  |> json.to_string
}
