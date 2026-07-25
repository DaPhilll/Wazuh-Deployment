# Headless Wazuh agent deployment for Windows endpoints.
# Run elevated on the target endpoint (WKSTN-01).
#
# The agent version must be equal to or lower than the manager version.
# This lab runs a 4.11.x manager, so a matching 4.11.x agent is used.
# Confirm the exact patch version available at https://packages.wazuh.com/4.x/windows/

$AgentVersion = "4.11.2-1"
$ManagerIP    = "10.10.0.10"

# Retrieve the deployment package
Invoke-WebRequest -Uri "https://packages.wazuh.com/4.x/windows/wazuh-agent-$AgentVersion.msi" -OutFile "wazuh-agent.msi"

# Silent install. WAZUH_MANAGER registers the agent against the manager;
# without it the agent installs with no manager configured and never connects.
msiexec.exe /i "wazuh-agent.msi" /q WAZUH_MANAGER="$ManagerIP" WAZUH_AGENT_NAME="WKSTN-01"

# Start the agent service
Start-Service WazuhSvc
