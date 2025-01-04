import gleam/bit_array
import gleam/crypto

pub fn generate(secret: BitArray, url: String) -> String {
  let url = bit_array.from_string(url)
  let message = bit_array.append(secret, url)
  crypto.hash(crypto.Sha512, message) |> bit_array.base64_encode(True)
}

pub fn validate(secret: BitArray, url: String, token: String) -> Bool {
  generate(secret, url) == token
}
