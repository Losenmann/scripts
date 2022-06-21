FROM ghcr.io/home-assistant/home-assistant:stable
LABEL maintainer="virus14m@gmail.com"
RUN mkdir -p /config \
  && touch /config/configuration.yaml \
  && touch /config/automations.yaml && printf '[]' > /config/automations.yaml \
  && touch /config/scripts.yaml \
  && touch /config/scenes.yaml \
  && printf '# Loads default set of integrations. Do not remove.\n' > /config/configuration.yaml \
  && printf 'default_config:\n\n' >> /config/configuration.yaml \
  && printf '# Text to speech\n' >> /config/configuration.yaml \
  && printf 'tts:\n  - platform: google_translate\n\n' >> /config/configuration.yaml \
  && printf 'automation: !include automations.yaml\nscript: !include scripts.yaml\nscript: !include scripts.yaml\n\n' >> /config/configuration.yaml \
  && printf 'http:\n  server_port: 8123\n  use_x_forwarded_for: true\n  trusted_proxies:\n    - 0.0.0.0/0\n  ip_ban_enabled: true\n  login_attempts_threshold: 5\n' >> /config/configuration.yaml \
  && printf '  ssl_certificate: /config/fullchain.pem\n  ssl_key: /config/privkey.pem\n' >> /config/configuration.yaml
