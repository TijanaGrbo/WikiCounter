# Planning for failure 😨

### Unhappy customer number 1
###### The issue:
User clicks submit -> waits 30 seconds -> nothing happens -> user is charged and
order is shipped.

###### The cause:
My assumption would be that this one is a result of UI depending on the response from the API. So even though the order was created, paid and shipped, the request on the client maybe timed out after 30 secs and the UI wasn’t updated. 

###### The possible solution(s)
After the user taps on the button and the request fires:
* Disable the button if it’s visible
* Put the button in the loading state or show a spinner
* Since there’s probably some information available about the timeouts on the payment API server, it’s also probably a good idea to have a slightly longer timeout on the client. This would allow the server to send a response after the timeout with status codes or custom errors, and a client to have enough time to receive it.
* Keep the user informed about what’s going on. For example, if the timeout is 30 seconds, and the spinner is active, after maybe 15 seconds display something along the lines of “The request is taking longer than expected, hang in there”. If it times out, provide that information in a user-friendly wording.
* Depending on the concept of the website/app, it might be a good solution to just provide immediate feedback, something like “Your order has been sent 🙌 You’ll get a confirmation email/notification as soon as we process the order”. Their order is sent, their cart is empty and there’s no risk from accidentally re-submitting the order, unless they do the same process all over again. Meanwhile, the backend can process the request and the user can get an email/notification/updated order status after the client gets a response from the server, or an apology (“Something went wrong, we couldn’t confirm your order, here’s 10% discount valid for the next purchase.” The wording sucks, but don’t blame me, I’m not a copywriter 😄). 
### Unhappy customer number 2
###### The issue:
User clicks submit -> waits 45 seconds -> user is charged twice -> UI updates to say
order is shipped.

###### The cause:
The payment API was called two times and I’d guess that the request timed out and retried, hence two charges.

###### The possible solution(s)
**I want to emphasize that all suggestions from the first scenario also apply to other scenarios.** However, this problem requires additional safety measures, for example:
* Limit the number of retries, maybe space them a bit
* Generate an idempotency key and send it in the request header. Make sure you’re resending it with the request if you’re retrying. There can be multiple solutions using the idempotency key, and they vary based on how you generate it, for how long you want to store it, what you combine it with (user or device ID, for example), etc. 
* Make sure that your model has a field for tracking the payment status and update it accordingly when you get a response from the server.
* Before making a new request, check if there are other pending orders for the same:
  * user or device ID
  * order with the same ID and check the status of it. It might be an insignificant detail, but maybe ID can be the hash generated from the order details? The ID generated in such way might help compare the objects more quickly

### Unhappy customer number 3
###### The issue:
User clicks submit -> nothing happens -> user clicks submit again -> UI updates to
say order is shipped. User was charged twice, order shipped once.

###### The cause:
My first impression was that something might had blocked the main thread, therefore nothing happened when the user tapped on the button for the first time. Maybe the button state wasn’t updated (faulty logic for the state update?). Two requests were sent and only one order was shipped, probably because there has already been an order with the same ID in the database. Two payments went through because they were treated as separate payments, maybe because they were missing a unique identifier that would allow the server to identify them as duplicate requests.

###### The possible solution(s)
As in the previous scenarios:
* Check the logic for button state update, might want to disable it as soon as it’s tapped and not wait for the request to fire
* Put the button in the loading state or show a spinner
* If there’s a retry, or the request has been sent multiple times for whatever reason, generate the idempotency key, put it in the request header and make sure you send it with every retry. Maybe combine it with user or device ID as another layer of uniqueness.
* Store an order as a pending one until it gets resolved by the API response and check if there are any pending orders before sending out another request
