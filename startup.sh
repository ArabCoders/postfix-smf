#!/bin/bash

if [ -z "${PSMF_HOST}" ] || [ -z "${PSMF_DOMAINS}" ] || [ -z "${PSMF_MAPS}" ]
then
  echo 'Required ENV variables are missing.';
  exit 0
fi

echo ">> reducing the amount of spam processed by postfix"
# https://www.howtoforge.com/virtual_postfix_antispam

postconf -e smtpd_helo_required=yes
postconf -e strict_rfc821_envelopes=yes
postconf -e disable_vrfy_command=yes

postconf -e unknown_address_reject_code=554
postconf -e unknown_hostname_reject_code=554
postconf -e unknown_client_reject_code=554

postconf -e "smtpd_helo_restrictions=
              permit_mynetworks,\
              reject_non_fqdn_helo_hostname,\
              reject_unknown_helo_hostname,\
              reject_invalid_helo_hostname,\
              permit"

postconf -e "smtpd_recipient_restrictions=\
              reject_invalid_hostname,\
              reject_non_fqdn_hostname,\
              reject_non_fqdn_sender,\
              reject_non_fqdn_recipient,\
              reject_unknown_sender_domain,\
              reject_unknown_recipient_domain,\
              permit_mynetworks,\
              reject_unauth_destination,\
              reject_rbl_client cbl.abuseat.org,\
              reject_rbl_client sbl-xbl.spamhaus.org,\
              reject_rbl_client bl.spamcop.net, \
              reject_rhsbl_sender dsn.rfc-ignorant.org,\
              check_policy_service inet:127.0.0.1:10023,\
              permit"

#SSL?

if [ -e /data/cert.pem ] && [ -e /data/key.pem ]; then
  postconf -e "smtpd_tls_cert_file=/data/cert.pem";
  postconf -e "smtpd_tls_cert_file=/data/key.pem";
  postconf -e "smtpd_use_tls=yes";
fi

echo ">> setting up postfix for ${PSMF_HOST}"

# add domain
postconf -e myhostname="${PSMF_HOST}"
postconf -X mydestination

echo "${PSMF_HOST}" > /etc/mailname

#set up virtual domains and adresses
postconf -e virtual_alias_domains="${PSMF_DOMAINS}"
postconf -e virtual_alias_maps=hash:/etc/postfix/virtual

# add virtual addresses
IFS=";"
for x in ${PSMF_MAPS};
do
  echo "${x}" >> /etc/postfix/virtual
done

cat /etc/postfix/virtual

# map virtual addresses
postmap /etc/postfix/virtual

# starting services
echo ">> starting the services"
service rsyslog start
service postfix start

# print logs
echo ">> printing the logs"
touch /var/log/mail.log /var/log/mail.err /var/log/mail.warn
chmod a+rw /var/log/mail.*
tail -F /var/log/mail.*