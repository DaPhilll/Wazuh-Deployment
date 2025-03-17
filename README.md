# Wazuh-Deployment

## Objective

This project provides a step-by-step guide to deploy Wazuh, an open-source security information and event management (SIEM) and extended detection and response (XDR) platform, on a virtualized environment. The goal is to establish a functional Wazuh server on an Ubuntu VM and successfully integrate a Windows 10 agent for comprehensive endpoint monitoring. This setup enables users to gain practical experience with SIEM/XDR deployment, configuration, and basic log analysis.

### Skills Learned

-   Virtual machine creation and configuration using Oracle VirtualBox.
-   Linux server administration, including package management and firewall configuration (UFW).
-   Wazuh server installation and configuration, encompassing server, indexer (OpenSearch), and dashboard (OpenSearch Dashboards).
-   Windows 10 agent installation and configuration for endpoint monitoring.
-   Network configuration, specifically bridged networking for virtual machines.
-   Firewall rule management on both Linux and Windows platforms.
-   Basic understanding of SIEM/XDR concepts and their practical application.
-   Troubleshooting network connectivity and agent communication issues.

### Tools Used

-   Oracle VirtualBox for virtualization.
-   Ubuntu Desktop ISO for the Wazuh server VM.
-   Windows 10 ISO for the agent VM.
-   Wazuh 4.11.
-   OpenSearch and OpenSearch Dashboards.
-   UFW (Uncomplicated Firewall) for Linux firewall management.
-   Windows Defender Firewall with Advanced Security.

## Installation - Ubuntu VM and Wazuh Server

### 1. Create the Ubuntu VM

1.  Open Oracle VirtualBox and create a new virtual machine.
2.  Select "Linux" as the type and "Ubuntu (64-bit)" as the version.
3.  Allocate at least 8 GB of RAM.
4.  Create a virtual hard disk.
5.  In the VM's settings, go to "Network" and set "Attached to" to "Bridged Adapter."
6.  In "Storage," load the Ubuntu ISO into the virtual optical drive.
7.  Start the VM and follow the Ubuntu installation instructions.

### 2. Update and Install Dependencies

1.  Open a terminal in the Ubuntu VM.
2.  Update the package list and upgrade installed packages:

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

3.  Install `curl`:

    ```bash
    sudo apt install -y curl
    ```

### 3. Install Wazuh

1.  Download and execute the Wazuh installation script:

    ```bash
    curl -sO [https://packages.wazuh.com/4.11/wazuh-install.sh](https://packages.wazuh.com/4.11/wazuh-install.sh) && sudo bash ./wazuh-install.sh -a
    ```

2.  Save the displayed Wazuh dashboard URL and credentials securely.

### 4. Configure the Firewall (UFW)

1.  Enable UFW:

    ```bash
    sudo ufw enable
    ```

2.  Allow necessary ports:

    ```bash
    sudo ufw allow 1514/udp
    sudo ufw allow 1514/tcp
    sudo ufw allow 1515/tcp
    sudo ufw allow 55000/tcp
    sudo ufw allow 9200/tcp
    sudo ufw allow 5601/tcp
    sudo ufw allow 22/tcp # Optional, for SSH access
    ```

3.  Verify the firewall rules:

    ```bash
    sudo ufw status
    ```

### 5. Access the Wazuh Dashboard

1.  Open a web browser and navigate to the Wazuh dashboard URL.
2.  Log in using the saved credentials.

## Installation - Windows 10 Agent

### 1. Create the Windows 10 VM

1.  In Oracle VirtualBox, create a new virtual machine.
2.  Select "Microsoft Windows" as the type and "Windows 10 (64-bit)" as the version.
3.  Allocate at least 8 GB of RAM.
4.  Create a virtual hard disk.
5.  In the VM's settings, set "Attached to" to "Bridged Adapter."
6.  In "Storage," load the Windows 10 ISO.
7.  Start the VM and follow the Windows 10 installation instructions.

### 2. Install the Wazuh Agent on Windows 10

1.  Open PowerShell as administrator.
2.  Download the Wazuh agent installer:

    ```powershell
    Invoke-WebRequest -Uri "[https://packages.wazuh.com/4.x/windows/wazuh-agent-4.x-1.msi](https://packages.wazuh.com/4.x/windows/wazuh-agent-4.x-1.msi)" -OutFile "wazuh-agent.msi"
    ```

3.  Install the agent (replace `<wazuh_server_ip>`):

    ```powershell
    msiexec /i "wazuh-agent.msi" /quiet SERVERIP="<wazuh_server_ip>" SERVERPORT="1514"
    ```

4.  Start the Wazuh agent service:

    ```powershell
    Start-Service WazuhSvc
    ```

### 3. Configure Windows Firewall Rules

1.  Open "Windows Defender Firewall with Advanced Security."
2.  **Inbound Rules:**
    * Create new rules for UDP and TCP port 1514, allowing connections.
3.  **Outbound Rules:**
    * Create new rules for UDP and TCP port 1514, allowing connections.

### 4. Verify Agent Connection

1.  In the Wazuh dashboard, go to "Agents."
2.  Verify the Windows 10 agent is listed.

## Troubleshooting

* **Agent not appearing:** Verify IP addresses and firewall rules on both machines.
* **Wazuh dashboard not accessible:** Check network connectivity and firewall settings.
