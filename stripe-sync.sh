#!/bin/bash -e
# "exit immediately if a pipeline returns a non-zero status".
# https://stripe.com/docs/billing/prices-guide

# set the variable CURRENCY to a lowercase version of the currency code in config.toml.
CURRENCY=$(grep currency config.toml | cut -d'"' -f2 | tr [:upper:] [:lower:])

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

# -r = print to stdout without quotes. .[] = print every array. each product is printed as a block of 3 lines (name, sku, and price). there are no spaces between blocks.
sjq=$(jq -r '.[]|.name,.sku,.price' public/*/index.json)

if [[ ! -d data ]]; then

# create a product and price directory in data. redirect stderr to device null [why?]. if the exit status of mkdir is not 0, execute true (exit with a status code indicating success) [why?].
	mkdir -p data/product/ data/price 2>/dev/null || true

	echo "$sjq" |\
# loop through the stdout of 'jq'. make line 1 = the variable name.
	while read -r name
# make line 2 = the variable sku.
		read -r sku
# make line 3 = the variable price.
		read -r price
		do

		printf "Name: %s SKU: %s Price: %s\n" "$name" "$sku" "$price"

		stripeproduct=data/product/"$sku".json
		stripeprice=data/price/"$sku".json

# test if $stripeproduct exists. if so, execute curl (creates product on stripe). put output of curl into $stripeproduct. find and print the product id from file $stripeproduct.
		test -s "$stripeproduct" ||
		curl https://api.stripe.com/v1/products -u "${STRIPE_SECRET}:" -d name="$name" > "$stripeproduct"
		prodid=$(jq -r '.id' < "$stripeproduct")
		echo Product ID: "$prodid"

# test if $stripeprice exists. if so, execute curl (assigns price to product id). put output of curl into $stripeprice. find and print the product id from file $stripeprice.
		test -s "$stripeprice" ||
		curl https://api.stripe.com/v1/prices -u "${STRIPE_SECRET}:" -d product="$prodid" -d unit_amount="$price" -d currency="${CURRENCY}" > "$stripeprice"
		priceid=$(jq -r '.id' < "$stripeprice")
		echo Price ID: "$priceid"
	done
else
	while read sku
	do
		del=$(echo "$sjq" | grep -A1 -B1 "$sku") # find 1 line above and below the sku.
		sjq=${sjq/"$del"$'\n'/}
		sjq=${sjq/"$del"/} # the last product block has no newline char
	done <<< "$(ls data/product/ | cut -d'.' -f1)" # find the skus for already existing products. (is a here string).

	sjq1="$sjq"
#	sjq1=${sjq::-1} # remove trailing newline.
	echo "$sjq1" |\
	while read -r name
		read -r sku
		read -r price
		do

		printf "Name: %s SKU: %s Price: %s\n" "$name" "$sku" "$price"

		stripeproduct=data/product/"$sku".json
		stripeprice=data/price/"$sku".json

		test -s "$stripeproduct" ||
		curl https://api.stripe.com/v1/products -u "${STRIPE_SECRET}:" -d name="$name" > "$stripeproduct"
		prodid=$(jq -r '.id' < "$stripeproduct")
		echo Product ID: "$prodid"

		test -s "$stripeprice" ||
		curl https://api.stripe.com/v1/prices -u "${STRIPE_SECRET}:" -d product="$prodid" -d unit_amount="$price" -d currency="${CURRENCY}" > "$stripeprice"
		priceid=$(jq -r '.id' < "$stripeprice")
		echo Price ID: "$priceid"
	done
fi

sjq=$(jq -r '.[]|.sku' public/*/index.json)
echo "$sjq" |\
	while read sku
	do
	prodid=$(jq -r '.id' data/product/"$sku".json)
	priceid=$(jq -r '.id' data/price/"$sku".json)
	price1=$(jq -r '.[]|.price, .sku' public/*/index.json | grep -B1 "$sku" | head -n 1)
	price2=$(jq -r '.unit_amount' data/price/"$sku".json)
	if [ "$price1" -ne "$price2" ]; then
		stripeprice=data/price/"$sku".json
		curl https://api.stripe.com/v1/prices/"$priceid" -u "${STRIPE_SECRET}:" -d active=false > /dev/null
		curl https://api.stripe.com/v1/prices -u "${STRIPE_SECRET}:" -d product="$prodid" -d unit_amount="$price1" -d currency="${CURRENCY}" > "$stripeprice"
	fi
	done
