#!/bin/bash
# Host firewall rules for the Wazuh management plane (SRV-SOC01).

sudo ufw enable
sudo ufw allow 1514/udp     # Telemetry ingestion
sudo ufw allow 1514/tcp     # Telemetry ingestion
sudo ufw allow 1515/tcp     # Agent registration
sudo ufw allow 55000/tcp    # REST API management
sudo ufw allow 9200/tcp     # Indexer API
sudo ufw allow 5601/tcp     # Web dashboard
