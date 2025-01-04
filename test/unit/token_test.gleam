import gleeunit/should
import token

pub fn token_is_correct_using_same_secret_test() {
  let secret = <<"mySecret">>
  let url = "https://image.com/1"

  let token = token.generate(secret, url)

  token.validate(secret, url, token) |> should.be_true
}

pub fn token_is_incorrect_using_different_secrets_test() {
  let secret_to_generate = <<"myMaliciousSecret">>
  let secret_to_validate = <<"mySecret">>
  let url = "https://image.com/1"

  let token = token.generate(secret_to_generate, url)

  token.validate(secret_to_validate, url, token) |> should.be_false
}

pub fn token_used_for_different_url_is_incorrect_test() {
  let secret = <<"mySecret">>
  let url = "https://image.com/1"
  let different_url = "https://image.com/2"

  let token = token.generate(secret, different_url)

  token.validate(secret, url, token) |> should.be_false
}
