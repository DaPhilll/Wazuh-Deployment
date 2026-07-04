# Headless Wazuh agent deployment for Windows endpoints.
# Run elevated on the target endpoint (WKSTN-01).

# Retrieve the deployment package
Invoke-WebRequest -Uri "https://packages.wazuh.com/4.11/windows/wazuh-agent-4.11-1.msi" -OutFile "wazuh-agent.msi"

# Silent install with management plane parameters
msiexec /i "wazuh-agent.msi" /quiet SERVERIP="10.10.0.10" SERVERPORT="1514"

# Start the agent service
Start-Service WazuhSvc
