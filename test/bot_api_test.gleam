import api/bot
import gleam/json
import gleeunit/should

pub fn bot_api_decode_test() {
  let urls = ["url1", "url2"]
  let data = bot_api_test_data(urls)

  bot.decode(data) |> should.equal(Ok(urls))
}

fn bot_api_test_data(urls: List(String)) -> String {
  json.object([
    #(
      "images",
      json.array(urls, fn(url) { json.object([#("url", json.string(url))]) }),
    ),
  ])
  |> json.to_string
}
