import gleam/bit_array
import gleam/result
import glenvy/dotenv
import glenvy/env

pub type AppConfig {
  AppConfig(bot_api_base_url: String, port: Int, secret: BitArray)
}

pub fn load_from_env() -> Result(AppConfig, String) {
  let _ = dotenv.load()

  use bot_api_base_url <- result.try(read_env_var(
    "BOT_API_BASE_URL",
    env.get_string,
  ))

  use port <- result.try(read_env_var("PORT", env.get_int))

  use secret <- result.try(read_env_var("TOKEN_SECRET", env.get_string))
  use secret <- result.try(
    bit_array.base64_decode(secret)
    |> result.replace_error("Could not decode from base64"),
  )

  Ok(AppConfig(bot_api_base_url:, port:, secret:))
}

fn read_env_var(
  name: String,
  read_fun: fn(String) -> Result(a, env.Error),
) -> Result(a, String) {
  read_fun(name)
  |> result.replace_error("Incorrect value for env var '" <> name <> "'")
}
