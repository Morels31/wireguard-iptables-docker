FROM debian:latest
RUN apt update
RUN apt upgrade -y
RUN apt install iptables wireguard-tools iproute2 openresolv curl -y
COPY startup.sh /startup.sh
RUN chmod 700 /startup.sh
CMD ["/startup.sh"]


HEALTHCHECK --start-interval=3s --start-period=30s --interval=300s \
	CMD test -f /started || exit 1
