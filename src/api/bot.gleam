import config
import gleam/dynamic
import gleam/erlang/port
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/result
import gleam/uri

pub fn get_all(config: config.AppConfig) -> Result(List(String), String) {
  let url = config.bot_api_base_url <> "/image"

  use req <- result.try(
    request.to(url)
    |> result.replace_error("Failed to parse url '" <> url <> "'"),
  )
  use resp <- result.try(
    httpc.send(req) |> result.replace_error("Failed to make request"),
  )
  use urls <- result.try(
    decode(resp.body) |> result.replace_error("Failed to decode response"),
  )
  Ok(urls)
}

pub fn decode(json_string: String) -> Result(List(String), json.DecodeError) {
  json.decode(
    json_string,
    dynamic.field("images", dynamic.list(dynamic.field("url", dynamic.string))),
  )
}
