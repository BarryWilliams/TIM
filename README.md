# TIMmy - Trouble-Inflicted MiniApp
An app that fails

## Uses
This app can be placed into various failure modes. For example, the app can simulate a memory leak, high CPU usage, or going brain-dead.

This is dedicated to my good friend Tim.

## Routes

* `/cpu` - random CPU usage
* `/fullcpu` - full CPU usage
* `/memory` - memory leak
* `/kill` - full stop of the application
* `/braindead` - kill the web server, but the app stays running
* `/alive` - useful for liveness probes
* `/ready` - useful for readiness probes

## Startup environment variables
### `READY_MODE`
* "`normal`" (Default) : the ready endpoint responds with HTTP `200` after 30 seconds from app start
* "`fast`" : the ready endpoint responds with HTTP `200` immediately
* "`never`" : the `/ready` endpoint always responds with HTTP `500`

### `CONSUMED_CPU_MODE`
* "`minimal`" (Default) : uses only enough CPU to fulfill requests
* "`full`" : uses a constant 100%
* "`random`" : uses a random amount of CPU between 0% and 100%

### `CONSUMED_MEMORY_MODE`
* "`minimal`" (Default) : uses only needed RAM
* "`unlimited`" : increases the amount of memory used indefinitely until OOM kill

### `HTML_BG_COLOR`
You can specify any HTML color. The default is `white`. See [HTML Color Names](https://www.w3schools.com/colors/colors_names.asp)

