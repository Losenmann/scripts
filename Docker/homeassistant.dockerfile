FROM ghcr.io/home-assistant/home-assistant:stable
LABEL maintainer="virus14m@gmail.com"
RUN grep 'http:' /config/configuration.yaml \
  || printf '\nhttp:\n  server_port: 8123\n  use_x_forwarded_for: true\n  trusted_proxies:\n    - 0.0.0.0/0\n  ip_ban_enabled: true\n  login_attempts_threshold: 5\n' \
  >> /config/configuration.yaml
