# Unfortunately, Claude Code native install needs 8GB RAM to install, so build with --memory option:
docker build --memory 8g -f install-0-all.dockerfile -t win10-gembox-skill-all .
