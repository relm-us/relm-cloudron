#!/bin/sh

# Set defaults if not provided
: "${RELM_SERVER_URL:=http://localhost:3000}"
: "${RELM_ASSETS_URL:=${RELM_SERVER_URL}/asset}"
: "${RELM_FONTS_URL:=https://fonts.bunny.net/css}"
: "${RELM_LOGO_URL:=/logo.png}"
: "${RELM_LANG_DEFAULT:=en}"
: "${RELM_HOME_REDIRECT:=https://www.relm.us}"

# Output to config.js
cat <<EOF > /app/code/client/dist/config.js
window.config = {
  assetsUrl: "${RELM_ASSETS_URL}",
  fontsUrl: "${RELM_FONTS_URL}",
  logoUrl: "${RELM_LOGO_URL}",
  langDefault: "${RELM_LANG_DEFAULT}",
  server: "${RELM_SERVER_URL}",
  home: "${RELM_HOME_REDIRECT}"
};
EOF

# Run the original command (e.g., nginx or serve)
exec "$@"
