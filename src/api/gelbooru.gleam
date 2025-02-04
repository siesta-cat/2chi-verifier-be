import gleam/dynamic/decode
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

fn decode(json_string: String) -> Result(List(String), json.DecodeError) {
  let url_decoder = {
    use field <- decode.field("file_url", decode.string)
    decode.success(field)
  }

  let post_decoder = {
    use post <- decode.field("post", decode.list(url_decoder))
    decode.success(post)
  }

  json.parse(json_string, post_decoder)
}
