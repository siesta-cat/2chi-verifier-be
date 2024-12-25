import bravo
import bravo/uset
import gelbooru
import gleam/result

pub type ImageCache =
  uset.USet(String)

pub fn new() -> ImageCache {
  let assert Ok(table) = uset.new("cache", 1, bravo.Public)
  let assert Ok(_) = repopulate(table)
  table
}

pub fn next(cache: ImageCache) -> Result(String, String) {
  case uset.first(cache) {
    Ok(first) -> {
      uset.delete_key(cache, first)
      Ok(first)
    }
    Error(_) -> {
      use _ <- result.try(repopulate(cache))
      next(cache)
    }
  }
}

fn repopulate(cache: ImageCache) -> Result(Nil, String) {
  use urls <- result.try(gelbooru.fetch_image())
  uset.insert(cache, urls)
  Ok(Nil)
}
