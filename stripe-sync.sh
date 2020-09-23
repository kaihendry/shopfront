#!/bin/bash
# https://stripe.com/docs/billing/prices-guide
stripesecret=sk_test_fAZaJSuP4s2LQlu45SOFGFQO:

for p in public/*/index.json
do
jq -r '.[]|.name,.sku,.price' $p |
	while read -r name
	read -r sku
	read -r price
	do
	printf "Name: %s SKU: %s Price: %s\n" "$name" "$sku" "$price"
	stripeproduct=data/products/$sku.json
	test -f $stripeproduct || curl https://api.stripe.com/v1/products -u $stripesecret -d name="$name" > $stripeproduct
	jq < $stripeproduct
	done
done
