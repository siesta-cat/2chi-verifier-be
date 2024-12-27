import gleam/dynamic
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/json
import gleam/result

pub fn get_images_page(page_id: Int) -> Result(List(String), String) {
  let url = compose_url(page_id)

  use req <- result.try(
    request.to(compose_url(page_id))
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

fn compose_url(page_id: Int) {
  "https://gelbooru.com/index.php?page=dapi&s=post&q=index&json=1&tags=sleeping%202girl&pid="
  <> int.to_string(page_id)
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
