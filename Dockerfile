FROM ubuntu:latest

RUN echo mail > /etc/hostname

# install
ENV DEBIAN_FRONTEND non-interactive
RUN apt-get update -q && apt-get install -y postfix sasl2-bin rsyslog

# EXPOSE
EXPOSE 25 587

# Add startup script
ADD startup.sh /startup.sh
RUN chmod a+x /startup.sh

# Docker startup
ENTRYPOINT ["/startup.sh"]
