# FunboxLinks

## Installation (using docker)

Install and run application:
```bash
docker-compose up -d
```
Wait until compilation finished and then start using the application.

Run unit tests inside docker:
```bash
docker-compose exec web mix test
```
Stop application:
```bash
docker-compose down
```

## Usual installation

### Requirments
	* elixir ~> 1.9
	* redis ~> 5

```
git clone https://github.com/epanchee/elixir_task
mix do deps.get, deps.compile, compile
export REDIS_ADDR=[put your redis server address here]
```

Run the application
```bash
mix run --no-halt
```

## Usage
FunboxLinks API will be available on the address `localhost:4000`.

## Examples

* Request
```json
POST /visited_links
{
	"links": [
		"https://ya.ru",
		"https://ya.ru?q=123",
		"funbox.ru",
		"https://stackoverflow.com/questions/11828270/how-to-exit-the-vim-editor"
	]
}
```

* Result
```json
{
	"status": "ok"
}
```

* Request
```
GET /visited_domains?from=1545221231&to=1545217638
```

* Result
```json
{
	"domains": [
		"ya.ru",
		"funbox.ru",
		"stackoverflow.com"
	],
	"status": "ok"
}
```