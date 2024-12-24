import gleam/dynamic
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/list
import gleam/result

const url = "https://gelbooru.com/index.php?page=dapi&s=post&q=index&json=1&tags=sleeping%202girl&pid=0&limit=1"

pub fn fetch_image() -> Result(String, Nil) {
  use req <- result.try(request.to(url))
  use resp <- result.try(httpc.send(req) |> result.replace_error(Nil))
  use images <- result.try(decode(resp.body) |> result.replace_error(Nil))
  use image <- result.try(list.first(images))
  Ok(image)
}

pub fn decode(json_string: String) -> Result(List(String), json.DecodeError) {
  json.decode(
    json_string,
    dynamic.field(
      "post",
      dynamic.list(dynamic.field("file_url", dynamic.string)),
    ),
  )
}
