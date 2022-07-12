#!/bin/bash -e
# "exit immediately if a pipeline returns a non-zero status".
# https://stripe.com/docs/billing/prices-guide

# set the variable CURRENCY to a lowercase version of the currency code in config.toml.
CURRENCY=$(grep currency config.toml | cut -d'"' -f2 | tr [:upper:] [:lower:])

# create a product and price directory in data. redirect stderr to device null [why?]. if the exit status of mkdir is not 0, execute true (exit with a status code indicating success) [why?].
mkdir -p data/product/ data/price 2>/dev/null || true

# if .env exists and is a regular file, refresh the shell to include $STRIPE_SECRET as an environment variable. else, exit with notice.
if test -f .env
then
	source .env
else
	echo "Missing environment file: .env ."
	exit
fi

# if the length of $STRIPE_SECRET is not nonzero (doesn't exists) (tested by "if !"), exit with notice.
if ! test "$STRIPE_SECRET"
then
	echo "Please set \$STRIPE_SECRET (\"echo STRIPE_SECRET=sk_... > .env\")."
	exit
fi

for p in public/*/index.json
do
	jq -r '.[]|.name,.sku,.price' "$p" |
	while read -r name
		read -r sku
		read -r price
		do

		printf "Name: %s SKU: %s Price: %s\n" "$name" "$sku" "$price"

		stripeproduct=data/product/$sku.json
		stripeprice=data/price/$sku.json

		test -s "$stripeproduct" ||
		curl https://api.stripe.com/v1/products -u "${STRIPE_SECRET}:" -d name="$name" > "$stripeproduct"
		prodid=$(jq -r '.id' < "$stripeproduct")
		echo Product ID: "$prodid"

		# TODO: Check for price change
		test -s "$stripeprice" ||
		curl https://api.stripe.com/v1/prices -u "${STRIPE_SECRET}:" -d product="$prodid" -d unit_amount="$price" -d currency="${CURRENCY}" > "$stripeprice"
		priceid=$(jq -r '.id' < "$stripeprice")
		echo Price ID: "$priceid"

	done
done
