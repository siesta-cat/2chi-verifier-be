import app
import gleam/dynamic
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/result
import wisp

pub fn get_all(config: app.Config) -> Result(List(String), String) {
  let url = config.bot_api_base_url <> "/images"

  wisp.log_info("Loading URLs from bot API...")

  use req <- result.try(
    request.to(url)
    |> result.replace_error("Failed to parse URL '" <> url <> "'"),
  )
  use resp <- result.try(
    httpc.send(req) |> result.replace_error("Failed to make request"),
  )

  use urls <- result.try(
    decode(resp.body) |> result.replace_error("Failed to decode response"),
  )
  Ok(urls)
}

fn decode(json_string: String) -> Result(List(String), json.DecodeError) {
  json.decode(
    json_string,
    dynamic.field("images", dynamic.list(dynamic.field("url", dynamic.string))),
  )
}
