import app
import gleam/bit_array
import gleam/result
import glenvy/dotenv
import glenvy/env

pub fn load_from_env() -> Result(app.Config, String) {
  let _ = dotenv.load()

  use bot_api_base_url <- result.try(read_env_var(
    "BOT_API_BASE_URL",
    env.get_string,
  ))

  use port <- result.try(read_env_var("PORT", env.get_int))

  use token_secret <- result.try(read_env_var("TOKEN_SECRET", env.get_string))
  use token_secret <- result.try(
    bit_array.base64_decode(token_secret)
    |> result.replace_error("Could not decode from base64"),
  )

  use api_app_name <- result.try(read_env_var("API_APP_NAME", env.get_string))
  use api_secret <- result.try(read_env_var("API_SECRET", env.get_string))

  Ok(app.Config(bot_api_base_url:, port:, api_app_name:, api_secret:, token_secret:))
}

fn read_env_var(
  name: String,
  read_fun: fn(String) -> Result(a, env.Error),
) -> Result(a, String) {
  read_fun(name)
  |> result.replace_error("Incorrect value for env var '" <> name <> "'")
}
