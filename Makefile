.PHONY: data clean

data:
# checks if index.json already exists (for future use):
# ifeq (, $(wildcard $(wildcard public/*/index.json)))
# 	hugo
# endif
	rm -rf public/*
	hugo
	./stripe-sync.sh
	rm -rf public/*
	hugo

clean: # You will probably want to archive all your products on Stripe if you do this
	rm -rf data
