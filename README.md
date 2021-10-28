# README

This project contains a limited code sample which is similar to what we do in Zlick Paywall. Overall, the code is in a bad shape and we need your help as a Rails lead in our team to help refactor this code, improve its reliability and readability, and suggest us how to write tests for the more relevant parts of it.

It contains a controller called "StripeController". That controller handles a Stripe webhook event ("invoice.paid") and confirms a subscription for the first time or extends the expiry of an existing subscription on recurring payment. 

It also sends out some emails and adds users to marketing lists in Sendgrid after payment success.

Please note that this project only contains code snippets. It is not expected to actually run. 
