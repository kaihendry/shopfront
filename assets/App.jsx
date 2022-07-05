/** @jsx jsx */
import { loadStripe } from '@stripe/stripe-js'
import { jsx } from 'theme-ui'
import { Flex } from 'theme-ui'
import Products from './components/products'
import CartDisplay from './components/cart-display'
import { CartProvider } from 'use-shopping-cart'

const countryisofromcurrencyiso = [process.env.CURRENCY.slice(0, -1)]

const stripePromise = loadStripe(process.env.REACT_APP_STRIPE_API_PUBLIC)

const App = () => {
  return (
    <CartProvider
      mode='client-only'
      stripe={stripePromise}
	  // https://stripe.com/docs/payments/checkout/client#collect-shipping-address
// uses the currency code specified in config.toml
	  allowedCountries={countryisofromcurrencyiso}
//	  allowedCountries={['SG', 'US']}
      billingAddressCollection={false}
      successUrl={process.env.BaseURL + "/stripe/success"}
      cancelUrl={process.env.BaseURL + "/stripe/cancel"}
      currency={process.env.CURRENCY}>

      <Flex sx={{ justifyContent: 'space-evenly' }}>
        <Products products={productData} />
        <CartDisplay />
      </Flex>
    </CartProvider>
  )
}
export default App
