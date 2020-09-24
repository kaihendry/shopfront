#!/bin/bash -e
# https://stripe.com/docs/billing/prices-guide

# TODO: Lookup CURRENCY from config.toml

mkdir -p data/product/ data/price 2>/dev/null || true

if test -f .env
then
	source .env
else
	echo Missing environment file: .env
	exit
fi

if ! test "$STRIPE_SECRET"
then
	echo Please set \$STRIPE_SECRET sk_..
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
		curl https://api.stripe.com/v1/prices -u "${STRIPE_SECRET}:" -d product="$prodid" -d unit_amount="$price" -d currency="${CURRENCY:-"usd"}" > "$stripeprice"
		priceid=$(jq -r '.id' < "$stripeprice")
		echo Price ID: "$priceid"

	done
done
