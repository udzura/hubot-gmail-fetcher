hubot-gmail-fetcher
==============================

[Hubot](http://hubot.github.com/) script to fetch Gmail.

## Installation

### package.json

    ...
    "dependencies": {
      "hubot":        ">= 2.4.0 < 3.0.0",
      ...
      "hubot-gmail-fetcher": ">= 0.1.0"
    },
    ...

### On the edge

    ...
    "dependencies": {
      "hubot":        ">= 2.4.0 < 3.0.0",
      ...
      "hubot-gmail-fetcher": "udzura/hubot-gmail-fetcher"
    },
    ...

#### external-scripts.json

    ["hubot-gmail-fetcher"]

Run `npm install` to install hubot-gmail-fetcher and dependencies.


## Environmental variables

```
GMAIL_USER # - user
GMAIL_PASSWORD # - password
GMAIL_LABEL # - Google label name
GMAIL_FETCH_INTERVAL # default fetch interval(mins)
```

## Practical Use

Use `hubot help` or check the gmail-fetcher.coffee file to get the full list of options with short descriptions. 

```
hubot fetch-gmail change <mins> - Change the interval of gmail updates
hubot fetch-gmail start - Start the gmail update via IMAP
hubot fetch-gmail stop - Stop the gmail update
```

## TODO

* tests

## Contributing

Usual github way.
