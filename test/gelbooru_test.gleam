import gelbooru
import gleam/function
import gleam/json
import gleeunit/should

pub fn gelbooru_decode_test() {
  let data = gelbooru_test_data()
  gelbooru.decode(data) |> should.be_ok
}

fn gelbooru_test_data() -> String {
  json.object([
    #("@attributes", json.object([])),
    #(
      "post",
      json.array(
        [
          json.object([#("file_url", json.string("https://image1.com"))]),
          json.object([#("file_url", json.string("https://image2.com"))]),
          json.object([#("file_url", json.string("https://image3.com"))]),
        ],
        function.identity,
      ),
    ),
  ])
  |> json.to_string
}
