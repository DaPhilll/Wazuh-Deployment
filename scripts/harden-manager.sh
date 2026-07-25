#!/bin/bash
# Host firewall rules for the Wazuh management plane (SRV-SOC01).

sudo ufw enable
sudo ufw allow 1514/tcp     # Agent telemetry
sudo ufw allow 1514/udp     # Agent telemetry
sudo ufw allow 1515/tcp     # Agent enrollment
sudo ufw allow 55000/tcp    # Wazuh server REST API
sudo ufw allow 9200/tcp     # Wazuh indexer API
sudo ufw allow 443/tcp      # Wazuh dashboard (HTTPS)
