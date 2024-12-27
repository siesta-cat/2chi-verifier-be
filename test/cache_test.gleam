import cache
import gleam/list
import gleam/result
import gleam/set
import gleam/yielder
import gleeunit/should
import wisp

pub fn cache_server_from_different_pages_test() {
  let pages = pages_from_sizes([2, 3, 5])
  let cache = cache.new(fetcher_stub(pages, _), set.new())
  let urls = list.flatten(pages) |> set.from_list()

  let actual =
    Ok(set.map(urls, fn(_) { cache.next(cache) |> result.unwrap("") }))

  actual |> should.equal(Ok(urls))
}

pub fn cache_filters_bot_images_test() {
  let filter_url = random_url()
  let urls = set.from_list([filter_url, random_url(), random_url()])
  let pages = [set.to_list(urls)]
  let cache = cache.new(fetcher_stub(pages, _), set.from_list([filter_url]))
  let filtered_urls = set.filter(urls, fn(url) { url != filter_url })

  // TODO: do something like "run_times" instead of using the list size to do that
  let actual =
    Ok(set.map(filtered_urls, fn(_) { cache.next(cache) |> result.unwrap("") }))

  actual |> should.equal(Ok(filtered_urls))
}

fn fetcher_stub(
  pages: List(List(String)),
  page_id: Int,
) -> Result(List(String), String) {
  case list.drop(pages, page_id) {
    [] -> Error("page_id too large")
    [page, ..] -> Ok(page)
  }
}

fn pages_from_sizes(sizes: List(Int)) -> List(List(String)) {
  list.map(sizes, fn(i) {
    yielder.range(0, i - 1)
    |> yielder.map(fn(_) { random_url() })
    |> yielder.to_list()
  })
}

fn random_url() {
  "https://image.com/" <> wisp.random_string(10)
}
