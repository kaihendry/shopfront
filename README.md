Idea behind project https://dabase.com/blog/2020/Shop-front/

* [Intro and inspiration](https://www.youtube.com/watch?v=KtHz5JO7QS4)
* [Static Hugo client only MVP](https://www.youtube.com/watch?v=9TkttbV0Ydg)

# Local development

Install [hugo](https://gohugo.io/)

	npm i
	echo STRIPE_SECRET=sk... > .env
	edit config.toml
	hugo serve

Create products in `content/2020/`

# Product content file

Structure of product content:

	content/YYYY/SKU/index.md

In `content/2020/wrt1/index.md` the [Front
Matter](https://gohugo.io/content-management/front-matter/) is **the single
source of truth for product**. From `public/*/index.json`, the product listing
in JSON are synced with Stripe's backend, via `make`.

The individual product pages then reference the required [client-only
checkout](https://stripe.com/docs/js/checkout/redirect_to_checkout#stripe_checkout_redirect_to_checkout-options-lineItems-price)
**Price ID** from the `data/price` directory via [Hugo Data
templates](https://gohugo.io/templates/data-templates/).

# Stripe client-only mode

<img src="https://s.natalian.org/2020-09-23/cant-delete-product.png">

* https://useshoppingcart.com/usage/cartprovider#client-only-checkout-mode

# Data structure

Follows that of https://useshoppingcart.com/usage/cartprovider/ in `layouts/_default/single.html`.

# Delivery options

How to advertise **delivery limitations** ASAP, as to not waste anybodies time?

For example <https://online.vicsmeat.com.au/> asks for a post code off the bat.

Resolution: Offer a button to enable GPS to autofill their location but also allow them to type it in.

Stripe has a **shipping_address_collection.allowed_countries** as documented in [validateCartItems session](https://useshoppingcart.com/usage/validateCartItems())
