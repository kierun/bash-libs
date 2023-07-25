#!/bin/bash

# First take a copy of everything.
echo "Rsync"
rsync -chavzP --stats /home/yann/Maildir/ /home/yann/vault/Maildir/

# Second, remove whatever emails are older than a year.
echo "Finding old emails"
find /home/yann/Maildir/ -type f ! -name '*dovecot*' -mtime +365 -exec rm {} +
