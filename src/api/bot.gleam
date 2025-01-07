import gleam/dynamic
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/json
import gleam/result
import wisp

pub fn get_all(bot_api_base_url: String) -> Result(List(String), String) {
  let url = bot_api_base_url <> "/images"

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

pub fn post_image_review(
  bot_api_base_url: String,
  url: String,
  is_accepted: Bool,
  auth_token: String,
) -> Result(Nil, String) {
  use req <- result.try(
    request.to(bot_api_base_url <> "/images")
    |> result.replace_error("Failed to parse URL '" <> url <> "'"),
  )
  let status = case is_accepted {
    True -> "available"
    False -> "unavailable"
  }
  let json =
    json.object([
      #("url", json.string(url)),
      #("status", json.string(status)),
      #("tags", json.preprocessed_array([])),
    ])
  let req =
    req
    |> request.set_method(http.Post)
    |> request.set_header("Authorization", "Bearer " <> auth_token)
    |> request.set_header("content-type", "application/json")
    |> request.set_body(json.to_string(json))

  use resp <- result.try(
    httpc.send(req) |> result.replace_error("Failed to make request"),
  )

  case resp.status {
    201 -> {
      wisp.log_info(
        "Successfully added url '"
        <> url
        <> "' to the bot with status "
        <> status,
      )
      Ok(Nil)
    }
    _ -> Error("Bot API returned HTTP " <> int.to_string(resp.status))
  }
}

pub fn post_login(
  bot_api_base_url: String,
  api_app_name: String,
  api_secret: String,
) -> Result(String, String) {
  use req <- result.try(
    request.to(bot_api_base_url <> "/login")
    |> result.replace_error("Failed to parse URL '" <> bot_api_base_url <> "'"),
  )
  let json =
    json.object([
      #("app", json.string(api_app_name)),
      #("secret", json.string(api_secret)),
    ])
  let req =
    req
    |> request.set_method(http.Post)
    |> request.set_header("content-type", "application/json")
    |> request.set_body(json.to_string(json))

  use resp <- result.try(
    httpc.send(req) |> result.replace_error("Failed to make request"),
  )
  use token <- result.try(
    json.decode(resp.body, dynamic.field("token", dynamic.string))
    |> result.replace_error("Failed to decode token"),
  )

  Ok(token)
}

fn decode(json_string: String) -> Result(List(String), json.DecodeError) {
  json.decode(
    json_string,
    dynamic.field("images", dynamic.list(dynamic.field("url", dynamic.string))),
  )
}
