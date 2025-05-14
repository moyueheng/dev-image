
# Target section and Global definitions
# -----------------------------------------------------------------------------
.PHONY: all clean test install run deploy down

all: clean test install run deploy push

build: 
	bash ./update_tag.sh
	sudo docker compose build

deploy: 
	bash ./update_tag.sh
	sudo docker compose build
	sudo docker compose up -d

down:
	sudo docker compose down

push:
	sudo docker compose push

logs:
	sudo docker compose logs -f --tail 500