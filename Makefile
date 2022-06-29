.PHONY: data clean

data:
	hugo
	./stripe-sync.sh
	hugo

clean: # You will probably want to archive all your products on Stripe if you do this
	rm -rf data
