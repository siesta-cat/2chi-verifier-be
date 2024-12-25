import bravo
import bravo/uset
import gleam/int
import gleam/list
import gleam/result
import wisp

const page_id = "page_id"

type Fetcher =
  fn(Int) -> Result(List(String), String)

pub type ImageCache {
  ImageCache(
    urls: uset.USet(String),
    page_table: uset.USet(#(String, Int)),
    fetcher: Fetcher,
  )
}

pub fn new(fetcher: Fetcher) -> ImageCache {
  let assert Ok(urls) = uset.new("urls", 1, bravo.Public)
  let assert Ok(page_table) = uset.new("page_table", 1, bravo.Public)
  uset.insert(page_table, [#(page_id, 0)])

  let cache = ImageCache(urls:, page_table:, fetcher:)
  let assert Ok(_) = repopulate(cache)
  cache
}

pub fn next(cache: ImageCache) -> Result(String, String) {
  case uset.first(cache.urls) {
    Ok(first) -> {
      uset.delete_key(cache.urls, first)
      Ok(first)
    }
    Error(_) -> {
      use _ <- result.try(repopulate(cache))
      next(cache)
    }
  }
}

fn repopulate(cache: ImageCache) -> Result(Nil, String) {
  let page_id = get_current_page_id(cache)
  use urls <- result.try(cache.fetcher(page_id))
  increment_current_page_id(cache)
  uset.insert(cache.urls, urls)
  wisp.log_info(
    "Populated cache with " <> int.to_string(list.length(urls)) <> " urls",
  )
  Ok(Nil)
}

fn get_current_page_id(cache: ImageCache) -> Int {
  let assert Ok(#(_, page_id)) = uset.lookup(cache.page_table, page_id)
  page_id
}

fn increment_current_page_id(cache: ImageCache) {
  let value = get_current_page_id(cache) + 1
  uset.insert(cache.page_table, [#(page_id, value)])
  Nil
}
