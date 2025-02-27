import app
import envoy
import gleam/bit_array
import gleam/int
import gleam/result

pub fn load_from_env() -> Result(app.Config, String) {
  use bot_api_base_url <- result.try(read_env_var("BOT_API_BASE_URL", Ok))

  use port <- result.try(read_env_var("PORT", int.parse))

  use token_secret <- result.try(read_env_var("TOKEN_SECRET", Ok))
  use token_secret <- result.try(
    bit_array.base64_decode(token_secret)
    |> result.replace_error("Could not decode from base64"),
  )

  Ok(app.Config(bot_api_base_url:, port:, token_secret:))
}

fn read_env_var(
  name: String,
  read_fun: fn(String) -> Result(a, error),
) -> Result(a, String) {
  envoy.get(name)
  |> result.replace_error("Env var '" <> name <> "' not found")
  |> result.map(fn(value) {
    read_fun(value)
    |> result.replace_error("Incorrect value for env var '" <> name <> "'")
  })
  |> result.flatten()
}
