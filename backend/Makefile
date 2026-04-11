.PHONY: install build test typecheck deploy clean

PROJECTS := api ws-handler alert-checker

install:
	@for p in $(PROJECTS); do \
		echo "==> Installing $$p"; \
		(cd $$p && npm install) || exit 1; \
	done

build:
	@for p in $(PROJECTS); do \
		echo "==> Building $$p"; \
		(cd $$p && npm run build) || exit 1; \
	done

test:
	@for p in $(PROJECTS); do \
		echo "==> Testing $$p"; \
		(cd $$p && npm test) || exit 1; \
	done

typecheck:
	@for p in $(PROJECTS); do \
		echo "==> Typechecking $$p"; \
		(cd $$p && npm run typecheck) || exit 1; \
	done

deploy: build
	@for p in $(PROJECTS); do \
		echo "==> Deploying $$p"; \
		(cd $$p && npm run deploy) || exit 1; \
	done

clean:
	@for p in $(PROJECTS); do \
		rm -rf $$p/dist $$p/function.zip; \
	done
