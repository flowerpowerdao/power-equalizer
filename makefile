deploy-staging-locally:
	./deploy.zsh

deploy-staging-locally-full:
	./deploy.zsh local 2000

deploy-staging-ic:
	./deploy.zsh ic

deploy-staging-ic-full:
	./deploy.zsh ic 2000

deploy-production-ic-full:
	./deploy.zsh ic 2000 production