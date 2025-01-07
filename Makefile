.PHONY: test

run:
	docker compose down -v
	docker compose run --build twochi-verifier-be

test:
	docker compose down -v
	docker compose run --build twochi-verifier-be gleam test
