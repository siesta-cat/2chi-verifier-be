import bravo
import bravo/uset
import gleam/int
import gleam/list
import gleam/result
import wisp

const page_id = "page_id"

/// Fetcher acts as a wrapper for paginated APIs that provide URL resources.
/// It receives an Int, that indicates the page, and returns a list of URLs
type Fetcher =
  fn(Int) -> Result(List(String), String)

pub type UrlProvider {
  UrlProvider(
    urls: uset.USet(String),
    page_table: uset.USet(#(String, Int)),
    filter_urls: uset.USet(String),
    fetcher: Fetcher,
  )
}

pub fn new(fetcher: Fetcher, filter_urls: List(String)) -> UrlProvider {
  let table_id = random_id()
  let assert Ok(urls) =
    uset.new("urls" <> int.to_string(table_id), 1, bravo.Public)
  let assert Ok(page_table) =
    uset.new("page_table" <> int.to_string(table_id), 1, bravo.Public)
  uset.insert(page_table, [#(page_id, 0)])
  let assert Ok(filter_urls_table) =
    uset.new("filter_urls" <> int.to_string(table_id), 1, bravo.Public)
  uset.insert(filter_urls_table, filter_urls)

  let provider =
    UrlProvider(urls:, page_table:, filter_urls: filter_urls_table, fetcher:)
  let assert Ok(_) = repopulate(provider)
  provider
}

pub fn next(provider: UrlProvider) -> Result(String, String) {
  case uset.first(provider.urls) {
    Ok(first) -> {
      uset.delete_key(provider.urls, first)
      uset.insert(provider.filter_urls, [first])
      Ok(first)
    }
    Error(_) -> {
      use _ <- result.try(repopulate(provider))
      next(provider)
    }
  }
}

fn repopulate(provider: UrlProvider) -> Result(Nil, String) {
  let page_id = get_current_page_id(provider)
  use urls <- result.try(provider.fetcher(page_id))
  let urls =
    list.filter(urls, fn(url) {
      result.is_error(uset.lookup(provider.filter_urls, url))
    })
  increment_current_page_id(provider)
  uset.insert(provider.urls, urls)
  wisp.log_info(
    "Populated provider with " <> int.to_string(list.length(urls)) <> " URLs",
  )
  Ok(Nil)
}

fn get_current_page_id(provider: UrlProvider) -> Int {
  let assert Ok(#(_, page_id)) = uset.lookup(provider.page_table, page_id)
  page_id
}

fn increment_current_page_id(provider: UrlProvider) {
  let value = get_current_page_id(provider) + 1
  uset.insert(provider.page_table, [#(page_id, value)])
  Nil
}

fn random_id() -> Int {
  int.random(999_999_999_999_999)
}
