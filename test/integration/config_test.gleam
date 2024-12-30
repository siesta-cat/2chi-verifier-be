import config
import gleeunit/should

pub fn config_smoke_test() {
  config.load_from_env() |> should.be_ok()
}
