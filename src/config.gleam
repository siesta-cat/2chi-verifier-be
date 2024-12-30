import gleam/result
import glenvy/dotenv
import glenvy/env

pub type AppConfig {
  AppConfig(bot_api_base_url: String, port: Int)
}

pub fn load_from_env() -> Result(AppConfig, String) {
  let _ = dotenv.load()
  use bot_api_base_url <- result.try(read_env_var(
    "BOT_API_BASE_URL",
    env.get_string,
  ))
  use port <- result.try(read_env_var("PORT", env.get_int))
  Ok(AppConfig(bot_api_base_url:, port:))
}

fn read_env_var(
  name: String,
  read_fun: fn(String) -> Result(a, env.Error),
) -> Result(a, String) {
  read_fun(name)
  |> result.replace_error("Incorrect value for env var '" <> name <> "'")
}
