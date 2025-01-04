import gleam/bit_array
import gleam/crypto
import gleam/result

pub fn generate(secret: BitArray, url: String) -> String {
  bit_array.from_string(url)
  |> crypto.sign_message(secret, crypto.Sha512)
}

pub fn validate(secret: BitArray, url: String, token: String) -> Bool {
  let msg = crypto.verify_signed_message(token, secret)
  result.map(msg, fn(msg) { msg == bit_array.from_string(url) })
  |> result.unwrap(False)
}
