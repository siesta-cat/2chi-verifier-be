import gleam/bit_array
import gleam/crypto
import gleam/result

pub fn generate(secret: BitArray, url: String) -> String {
  bit_array.from_string(url)
  |> crypto.sign_message(secret, crypto.Sha512)
}

pub fn validate(secret: BitArray, token: String) -> Bool {
  crypto.verify_signed_message(token, secret) |> result.is_ok
}
