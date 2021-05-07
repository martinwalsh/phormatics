help:
	@echo "Requirements:"
	@echo "  - Python 3.5"
	@echo "      $$ brew install pyenv # (and caveats)"
	@echo "      $$ pyenv install 3.5.10"
	@echo "  - Poetry"
	@echo "      $$ pip install poetry"
	@echo ""
	@echo "Or use the docker targets."
	@echo ""
	@echo "Targets:"
	@echo "  build:    installs the python dependencies using poetry"
	@echo "  start:    starts the web application at http://localhost:5000"
	@echo "  notebook: starts the jupyter notebook"
	@echo "  clean:    removes build artifacts"
	@echo ""
	@echo "Docker Targets:"
	@echo "  docker-build: builds a docker image with python dependencies"
	@echo "  docker-start: starts the web application at http://localhost:5000 (in a docker container)"
	@echo "  docker-shell: starts a bash shell in the python container"
	@echo "  docker-clean: removes docker-compose artifacts"
.PHONY: help


server/models/mobilenet:
	mkdir -p $@


server/models/mobilenet/graph_opt.pb: | server/models/mobilenet
	curl -sSfLo "$@" "https://raw.githubusercontent.com/quanhua92/human-pose-estimation-opencv/master/graph_opt.pb"


build: server/models/mobilenet/graph_opt.pb
	poetry install
.PHONY: build


start: | build
	@echo "--> Launching web application, open you browser to http://localhost:5000"
	cd server/ && poetry run python app.py
.PHONY: start


notebook: | build
	poetry run jupyter notebook notebook.ipynb
.PHONY: notebook


clean:
	poetry env remove 3.5
.PHONY: clean


########################################################################################################
# DOCKER
docker-build:
	docker-compose build --pull
.PHONY: build


docker-start: server/models/mobilenet/graph_opt.pb | docker-build
	@echo "--> Launching web application, open you browser to http://localhost:5000"
	docker-compose up || true
	docker-compse down
.PHONY: docker-start


docker-shell: | docker-build
	@if ! docker-compose exec python bash -c 'exit 0' 2>/dev/null; then \
		docker-compose run --rm python bash;                              \
	else                                                               \
		docker-compose exec python bash;                                  \
	fi
.PHONY: docker-shell


docker-clean:
	docker-compose down --remove-orphans --volumes --rmi local
.PHONY: docker-clean
