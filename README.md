# MemePrism

Build status: [![Circle CI](https://circleci.com/gh/citizencode/MemePrism.svg?style=svg)](https://circleci.com/gh/citizencode/MemePrism)

## Setup

    npm install

## Publishing to Wordpress from a folder of emails (in mbox format)

Getting help:

     bin/prism update -h

Example:

    bin/prism update  --wp-url http://domain.of.your.wordpress.installation --wp-username <USERNAME> --wp-password <PASSWORD> --email-directory any/relative/path/to/emails/ 

