---
title: Channel Factories
uid: channel_factories
topic_page_or_best_reference: /en/topics/channel_factories/
excerpt: >
  Channel factories are an efficient way of creating payment channels.
  Multiple participants trustlessly combine their funds together using a
  single transaction.  From the combined funds, they create payment
  channels between each pair of participants, e.g. Alice with Bob, Bob
  with Carol, and Alice with Carol.  Although these are regular payment
  channels, the transactions opening the channels never need to appear
  on chain as long as the participants remain in cooperation with each
  other, allowing *n* users to open *n(n-1)/2* channels at the cost of
  opening and mutual transactions that are only roughly *n* times larger
  than standard open and mutual close transactions, e.g. 10 users can
  open 45 channels using transactions only 10x larger than normal.  In
  the case any participant violates the channel protocol, each
  participant has the independent ability to close their channel onchain
  in the proper state, ensuring the protocol remains trustless.


---
Test
