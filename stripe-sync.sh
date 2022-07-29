#!/bin/bash

if test -f .env
then
	source .env
else
	echo "Missing environment file: .env ."
	exit
fi
if ! test "$STRIPE_SECRET"
then
	echo "Please set \$STRIPE_SECRET (\"echo STRIPE_SECRET=sk_... > .env\")."
	exit
fi

#read -p "sk_...: " stripesecret
currency=$(grep currency config.toml | cut -d'"' -f2 | tr [:upper:] [:lower:])
publicjson=$(jq -r ".[] | .name,.sku,.price" public/*/index.json)

syncproduct () {
	curl https://api.stripe.com/v1/products -u "$STRIPE_SECRET": -d name="$1" > "$productjson"
}

syncprice () {
	productid=$(jq -r ".id" "$productjson")
	curl https://api.stripe.com/v1/prices -u "$STRIPE_SECRET": -d product="$productid" -d unit_amount="$1" -d currency="$currency" > "$pricejson"
}

if [[ ! -d data ]]; then
	mkdir -p data/product data/price
	echo "$publicjson" |\
	while read -r name
	read -r sku
	read -r price
	do
		productjson=data/product/"$sku".json
		pricejson=data/price/"$sku".json
		syncproduct "$name"
		syncprice "$price"
	done
else
	while read sku
	do
		a=$(echo "$publicjson" | grep -A1 -B1 "$sku")
		publicjson=${publicjson/"$a"$'\n'/}
		publicjson=${publicjson/"$a"/}
	done <<< $(ls data/product | cut -d"." -f1)
	echo "$publicjson" |\
	while read -r name
	read -r sku
	read -r price
	do
		productjson=data/product/"$sku".json
		pricejson=data/price/"$sku".json
		syncproduct "$name"
		syncprice "$price"
	done
fi
publicjsonskus=$(jq -r ".[] | .sku" public/*/index.json)
echo "$publicjsonskus" |\
while read sku
do
	productjson=data/product/"$sku".json
	pricejson=data/price/"$sku".json
	priceid=$(jq -r ".id" data/price/"$sku".json)
	price1=$(jq -r ".[] | .price,.sku" public/*/index.json | grep -B1 "$sku" | head -n 1)
	price2=$(jq -r ".unit_amount" data/price/"$sku".json)
	if [ "$price1" -ne "$price2" ]; then
		curl https://api.stripe.com/v1/prices/"$priceid" -u "$STRIPE_SECRET": -d active=false > /dev/null
		syncprice "$price1"
	fi
done
