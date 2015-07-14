# MemePrism

## Setup

    npm install

## Publishing to Wordpress from a folder of emails (in mbox format)

Prerequisite:

Getting help:

     bin/prism update -h

Example:

    bin/prism update  --wp-url http://domain.of.your.wordpress.installation --wp-username <USERNAME> --wp-password <PASSWORD> --email-directory any/relative/path/to/emails/

## Developing

### Debugging
Often it is difficult or impossible to discover what line number errors you encounter actually occur on.  Try this to debug.

```bash
$ npm install -g node-inspector
$ coffee --nodejs --debug ./server/app.coffee
$ node-inspector # in another tab
```
