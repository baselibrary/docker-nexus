NAME     = baselibrary/nexus
REPO     = git@github.com:baselibrary/docker-nexus.git
LOCAL    = 192.168.99.2
VERSIONS = $(foreach df,$(wildcard */Dockerfile),$(df:%/Dockerfile=%))

all: build

build: $(VERSIONS)

branches:
	git fetch $(REPO) master
	@$(foreach tag, $(VERSIONS), git branch -f $(tag) FETCH_HEAD;)
	@$(foreach tag, $(VERSIONS), git push $(REPO) $(tag);)
	@$(foreach tag, $(VERSIONS), git branch -D $(tag);)

.PHONY: all build library $(VERSIONS)
$(VERSIONS):
	docker build --rm -t $(NAME):$@ $@ && docker tag ${NAME}:$@ ${LOCAL}/${NAME}:$@ && docker push ${LOCAL}/${NAME}:$@ && docker rmi ${LOCAL}/${NAME}:$@
