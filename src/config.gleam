import decode
import gleam/dynamic
import gleam/result

// TODO: Add port
pub type AppConfig {
  AppConfig(bot_api_base_url: String)
}

pub fn load_from_env() -> Result(AppConfig, String) {
  use bot_api_base_url <- result.try(read_env_var(
    "BOT_API_BASE_URL",
    decode.string,
  ))
  Ok(AppConfig(bot_api_base_url:))
}

fn read_env_var(name: String, decoder: decode.Decoder(a)) -> Result(a, String) {
  decode.from(decoder, dynamic.from(name))
  |> result.map_error(fn(_) { "Invalid value of env var '" <> name <> "'" })
}
