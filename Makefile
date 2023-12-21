
# Target section and Global definitions
# -----------------------------------------------------------------------------
.PHONY: all clean test install run deploy down

all: clean test install run deploy down

deploy: 
	bash ./update_tag.sh
	docker-compose build
	docker-compose up -d

down:
	docker-compose down