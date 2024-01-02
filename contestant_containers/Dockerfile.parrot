FROM docker.io/parrotsec/core
RUN \
  echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/force-unsafe-io && \
  DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -o Dpkg::Options::="--force-confnew" update && \
  DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -o Dpkg::Options::="--force-confnew" dist-upgrade -y && \
  # missing parrot-desktop-xfce kismet, urh, gr-lora_sdr nrsc5
  DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -o Dpkg::Options::="--force-confnew" install --no-install-recommends aircrack-ng asleap freeradius-wpe hostapd-mana iw mdk3 mdk4 pixiewps reaver wifi-honey wifite tshark wireshark termshark vim mlocate man pciutils hashcat wpasupplicant less bash-completion ssh supervisor novnc xvfb x11vnc dbus-x11 dialog tmux tcpdump nmap curl gnuradio gqrx-sdr gr-osmosdr fldigi qsstv wsjtx make firefox-esr libnotify-bin -y --allow-remove-essential && \
  # hack around broken metapackages for kismet and parrot-desktop-xfce
  DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -o Dpkg::Options::="--force-confnew" install --no-install-recommends xfce4 kismet-core kismet-doc kismet-logtools kismet-capture-linux-wifi -y --allow-remove-essential && \
  apt-get autoremove --purge -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -f /etc/ssh/ssh_host_* && \
  cd /etc/freeradius-wpe/3.0/certs && \
  make clean && \
  cd /etc/hostapd-mana/certs && \
  rm ca.pem csr.csr dhparam.pem server.key server.pem

# Expose needed ports
EXPOSE 22/tcp
EXPOSE 8080/tcp

# Set operable environment
ENV DISPLAY=:0

COPY files/fava_beans.words /root/fava_beans.words
COPY files/supervisord-debianish.conf /etc/supervisord/supervisord.conf
COPY files/contestant-checker /usr/local/sbin/contestant-checker

WORKDIR /root
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord/supervisord.conf", "--pidfile", "/run/supervisord.pid"]
ENTRYPOINT []

HEALTHCHECK --interval=60s --start-period=30s --retries=2 CMD /usr/local/sbin/contestant-checker
