# STATUS: WIP, NOT EVEN AN MVP

Idea behind project https://dabase.com/blog/2020/Shop-front/

# Local development

Install [hugo](https://gohugo.io/)

	npm i
	echo STRIPE_SECRET=sk... > .env
	edit config.toml
	hugo serve

Create products in content/2020/

# Product content file

Structure of product content:

	content/YYYY/SKU/index.md

In content/2020/wrt1/index.md the [Front
Matter](https://gohugo.io/content-management/front-matter/) is **the single
source of truth for product**. From `public/*/index.json`, the product listing
in JSON are synced with Stripe's backend, via `make`.

The individual product pages then reference the required [client-only
checkout](https://stripe.com/docs/js/checkout/redirect_to_checkout#stripe_checkout_redirect_to_checkout-options-lineItems-price)
**Price ID** from the `data/price` directory via [Hugo Data
templates](https://gohugo.io/templates/data-templates/).

# Stripe client-only mode

<img src="https://s.natalian.org/2020-09-23/cant-delete-product.png">

* Integrate Stripe Connect
* Come up with some square image system: product before (packaged) / after (being served / consumed)
* https://useshoppingcart.com/usage/cartprovider#client-only-checkout-mode

# Data structure

Follows that of https://useshoppingcart.com/usage/cartprovider/

	const products = [
	  {
		name: 'Bananas',
		// sku ID from your Stripe Dashboard
		sku: 'sku_GBJ2Ep8246qeeT',
		// price in smallest currency unit (e.g. cent for USD)
		price: 400,
		currency: 'USD',
		// Optional image to be shown on the Stripe Checkout page
		image: 'https://my-image.com/image.jpg'
	  }
	]

This needs to be marked up in Hugo https://gohugo.io/content-management/front-matter/ in the **product content file** and will be outputed by a Hugo layout template.

Currency is set in the Hugo config `.params.currency`

# Delivery options

How to advertise **delivery limitations** ASAP, as to not waste anybodies time?

For example <https://online.vicsmeat.com.au/> asks for a post code off the bat.

Resolution: Offer a button to enable GPS to autofill their location but also allow them to type it in.

Stripe has a **shipping_address_collection.allowed_countries** as documented in [validateCartItems session](https://useshoppingcart.com/usage/validateCartItems())
