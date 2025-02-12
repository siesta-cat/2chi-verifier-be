import app
import config
import gleam/set
import gleeunit/should
import router
import url_provider
import wisp/testing

pub fn get_health_test() {
  let assert Ok(config) = config.load_from_env()
  let ctx =
    app.Context(
      url_provider: url_provider.new(fn(_) { Ok([]) }, set.new()),
      config:,
    )

  let response = router.handle_request(testing.get("/health", []), ctx)
  response.status |> should.equal(200)
}
