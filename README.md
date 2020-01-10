# Postfix Simple Mail Forwarder
docker container for forwarding emails to another email address(s), domain(s), or server(s).
For Example; forward emails from your custom domain to your gmail

## Example:
```bash
docker run -d -p 25:25 \
-e PSMF_HOST="mail.example.com" \
-e PSMF_DOMAINS="example.com" \
-e PSMF_MAPS="@example.com me@gmail.com" \
arabcoders/postfix-smf
```

this creates a new smtp server which listens on port 25 and  and forwards all email sent to example.com to me@gmail.com

## Required environment variables:

#### `PSMF_HOST`
hostname of your server  
for example `mail.example.com`

#### `PSMF_DOMAINS`
the domains you want to receive emails for, separated by spaces  
for example `example.com mysite.com etcetra.net`

#### `PSMF_MAPS`
maping between incoming emails and where to forward them. Use @mysite.com for catch all emails. Separate multiple rules using `;`  
for example `me@example.com me@gmail.com;@etcetra.net my-email@gmail.com`
