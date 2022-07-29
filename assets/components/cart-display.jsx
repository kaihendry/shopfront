/**@jsx jsx */
import { jsx, Box, Flex, Image, Button, Input } from 'theme-ui'
import { useShoppingCart } from 'use-shopping-cart'

const CartDisplay = () => {
  const {
    cartDetails,
    cartCount,
    formattedTotalPrice,
    redirectToCheckout,
    clearCart,
    setItemQuantity
  } = useShoppingCart()

  const handleSubmit = async (event) => {
    event.preventDefault()
	console.log("transform to lineitems:", cartDetails)

const lineItems = []
    for (const sku in cartDetails)
      lineItems.push({ price: sku, quantity: cartDetails[sku].quantity })

    const options = {
      mode: 'payment',
      lineItems,
      successUrl: `${process.env.BaseURL}/stripe/success`,
      cancelUrl: `${process.env.BaseURL}/stripe/cancel`,
      billingAddressCollection: false
        ? 'required'
        : 'auto',
      submitType: 'auto'
    }

	console.log("redirecting to Stripe for payment", options)
    redirectToCheckout(options)
  }

  if (Object.keys(cartDetails).length === 0) {
    return (
      <Box sx={{ textAlign: 'center' }}>
        <h2>Shopping Cart Display Panel</h2>
        <h3>No items in cart</h3>
      </Box>
    )
  } else {
    return (
      <Flex
        sx={{
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center'
        }}
      >
        <h2>Shopping Cart Display Panel</h2>
        {Object.keys(cartDetails).map((item) => {
          const cartItem = cartDetails[item]
          const { name, sku, quantity } = cartItem
          return (
            <Flex
              key={cartItem.sku}
              sx={{
                justifyContent: 'space-around',
                alignItems: 'center',
                width: '100%'
              }}
            >
              <Flex sx={{ flexDirection: 'column', alignItems: 'center' }}>
                <Image sx={{ width: 100 }} src={cartItem.image} />
                <p>{name}</p>
              </Flex>
              <Input
                type={'number'}
                max={99}
                sx={{ width: 60 }}
                defaultValue={quantity}
                onChange={(e) => {
                  const { value } = e.target
                  setItemQuantity(sku, value)
                }}
              />
            </Flex>
          )
        })}
        <h3>Total Items in Cart: {cartCount}</h3>
        <h3>Total Price: {formattedTotalPrice}</h3>
        <h4>The cart's total value must exceed .3 GBP (or equivalent) or nothing will happen!</h4>
        <Button sx={{ backgroundColor: 'black' }} onClick={handleSubmit}>
            Checkout
        </Button>
        <Button sx={{ backgroundColor: 'black' }} onClick={() => clearCart()}>
          Clear Cart Items
        </Button>
      </Flex>
    )
  }
}

export default CartDisplay
