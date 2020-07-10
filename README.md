# FunboxLinks

## Installation (using docker)

### Requirments
	* docker-compose >= 1.26
	* docker >= 19.03.12

To install and run application simply type:
```bash
docker-compose up
```
## Usual installation

### Requirments
	* elixir ~> 1.9
	* redis ~> 5

```bash
git clone https://github.com/epanchee/elixir_task
mix do deps.get, deps.compile, compile
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