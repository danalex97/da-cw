PROJECT = da-cw
NETWORK = $(PROJECT)_network
PEERS = 5

COMPOSE = MAIN=$(MAIN) PEERS=$(PEERS) docker-compose -p $(PROJECT)

compile:
	mix compile

clean:
	mix clean

build:
	$(COMPOSE) build

# make MAIN=System1.start local
local:
	mix run -e $(MAIN)

# need to add MAIN=... before
# e.g. build MAIN=... up
up:
	$(COMPOSE) up

down:
	$(COMPOSE) down
	make show

show:
	@echo ----------------------
	@make ps
	@echo ----------------------
	@make network

ps:
	docker ps -a -s

network net:
	docker network ls

inspect:
	docker network inspect $(NETWORK)

netrm:
	docker network rm $(NETWORK)
conrm:
	docker rm $(ID)

done:  # place within an 'if' in ~/.bash_logout
	docker rm -f `docker ps -a -q`
	docker network rm da347_network
