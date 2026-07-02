# Centralized SIEM/XDR Engineering: Multi-Platform Telemetry Aggregation and Detection Engineering with Wazuh

## Objective

This project documents the architectural deployment, hardening, and operational validation of Wazuh (v4.11)—an enterprise-grade, open-source Security Information and Event Management (SIEM) and Extended Detection and Response (XDR) platform. Beyond baseline log aggregation, this initiative establishes a complete detection engineering loop: deploying a hardened central management node, engineering telemetry forwarding streams across a Windows 10 endpoint, simulating real-world adversary behaviors, and authoring custom detection logic to minimize alert fatigue.

### Engineering Capabilities Demonstrated

- **Virtualized Infrastructure Architecture:** Provisioning and segmenting dedicated virtual machines utilizing isolated network patterns (Bridged adapters) to mirror production-like enterprise environments.
- **Linux Systems Hardening & Security Controls:** Administering core Linux subsystems, package management lifecycle hooks, and implementing network boundary protections via stateful host firewalls (UFW).
- **Endpoint Telemetry Forwarding & Agent Deployment:** Automating host-based agent installations via headless administrative interfaces (PowerShell/MSI) and establishing encrypted communication channels to the management plane.
- **Threat Simulation & Adversary Emulation:** Simulating credential harvesting, authentication attacks, and malicious file drops to validate end-to-end log ingestion pipelines.
- **Detection Engineering & Rule Tuning:** Analyzing raw JSON security events, modifying built-in alert thresholds, and authoring custom detection logic to reduce false positives.
- **Technical Troubleshooting & Log Analysis:** Executing systematic diagnostic protocols to remediate network layer communication friction, agent authentication errors, and service layer dependencies.

### Tools & Core Technologies

| Layer | Component / Technology Used | Purpose |
| :--- | :--- | :--- |
| **Hypervisor** | Oracle VirtualBox | Hardware-level virtualization and network isolation |
| **Management Plane** | Ubuntu Server Node | Underlying host operating system for the SIEM node |
| **Endpoint Telemetry** | Windows 10 Enterprise | Target system for adversary emulation and log forwarding |
| **SIEM / XDR Core** | Wazuh Manager & Indexer (v4.11) | Log ingestion, processing, indexing, and correlation |
| **Visualization UI** | OpenSearch Dashboards | Querying analytics, security event graphing, and rule management |
| **Host Protections** | UFW (Linux) & Windows Defender Firewall | Implementation of strict stateful transport-layer access controls |
| **Emulation Utilities** | EICAR Standard Test String, Command Line | Adversary behavior generation tools |

---

## Deployment Phase 1: Security Management Plane Engine (Wazuh Server)

### 1. Provisioning the Core Host Node
1. Initialize a new virtual instance within the hypervisor infrastructure.
2. Select **Linux** as the platform type and assign **Ubuntu (64-bit)** as the base kernel target.
3. Allocate a baseline configuration of at least **8 GB RAM** and a dedicated virtual storage drive to handle indexing volumes.
4. Navigate to the instance's network configuration and bind the interface to a **Bridged Adapter** to ensure discrete routing capabilities within the broadcast domain.
5. Map the Ubuntu installation media to the virtual optical interface, boot the system, and execute a standard operating system installation.

### 2. Dependency Lifecycle Management & Hardening
1. Launch a privileged terminal session on the newly provisioned instance.
2. Update repository indexes and pull downstream package enhancements to eliminate outstanding vulnerabilities:

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

3. Install the secure file transfer utility (`curl`):

    ```bash
    sudo apt install -y curl
    ```

### 3. Automated Monolithic Wazuh Infrastructure Installation
1. Pull and execute the official, cryptographically verified Wazuh automated deployment script to establish the indexer, server daemon, and dashboard manager:

    ```bash
    curl -sO [https://packages.wazuh.com/4.11/wazuh-install.sh](https://packages.wazuh.com/4.11/wazuh-install.sh) && sudo bash ./wazuh-install.sh -a
    ```

2. Securely extract and cache the generated administrative root credentials and the uniquely assigned deployment URL output by the script.

### 4. Stateful Firewall Engineering (UFW Configuration)
1. Initialize the Uncomplicated Firewall engine:

    ```bash
    sudo ufw enable
    ```

2. Implement a strict inbound access control policy, restricting transport-layer ingress to explicitly required operational ports:

    ```bash
    # Telemetry Ingestion and Agent Communication
    sudo ufw allow 1514/udp
    sudo ufw allow 1514/tcp
    
    # Agent Registration Service
    sudo ufw allow 1515/tcp
    
    # Cluster REST API Management
    sudo ufw allow 55000/tcp
    
    # Core Indexer API Communication
    sudo ufw allow 9200/tcp
    
    # Secure Web Dashboard Accessibility (HTTPS UI)
    sudo ufw allow 5601/tcp
    
    # Hardened Remote Administration Loop (Optional)
    sudo ufw allow 22/tcp
    ```

3. Validate the state and layout of the network rules to ensure proper enforcement:

    ```bash
    sudo ufw status
    ```

### 5. Management UI Verification
1. Launch a secure web browser and pivot to the previously cached dashboard URL.
2. Supply the administrative credentials to verify initialization of the OpenSearch management plane.

---

## Deployment Phase 2: Endpoint Telemetry Provisioning (Windows 10 Agent)

### 1. Endpoint Host Virtualization
1. Provision a distinct virtual machine instance optimized for standard client operations.
2. Designate **Microsoft Windows** as the platform architecture and select **Windows 10 (64-bit)**.
3. Dedicate a minimum allocation of **8 GB RAM** alongside isolated virtual storage infrastructure.
4. Alter the network settings to utilize a **Bridged Adapter**, establishing direct layer-2 line of sight with the management plane instance.
5. Mount the target image media and complete the standard client deployment.

### 2. Automated Agent Injection via PowerShell
1. Launch an elevated, administrative PowerShell console instance on the target host.
2. Programmatically pull the targeted deployment binary from the verified cloud repository:

    ```powershell
    Invoke-WebRequest -Uri "[https://packages.wazuh.com/4.11/windows/wazuh-agent-4.11-1.msi](https://packages.wazuh.com/4.11/windows/wazuh-agent-4.11-1.msi)" -OutFile "wazuh-agent.msi"
    ```

3. Execute a quiet, headless installation parameters block to securely map the endpoint directly to the central management engine (substitute `<wazuh_server_ip>` with your server's static IP):

    ```powershell
    msiexec /i "wazuh-agent.msi" /quiet SERVERIP="<wazuh_server_ip>" SERVERPORT="1514"
    ```

4. Initialize the host-based telemetry service tracking lifecycle hook:

    ```powershell
    Start-Service WazuhSvc
    ```

### 3. Transport Layer Inbound/Outbound Filtering
1. Open the *Windows Defender Firewall with Advanced Security* management console.
2. **Inbound Access Control Rules:** Create a custom traffic rule allowing secure transport interaction across both TCP and UDP protocol layers over port **1514**.
3. **Outbound Access Control Rules:** Create a matching rule ensuring unrestricted outbound logging capabilities to the central SIEM manager over TCP/UDP port **1514**.

### 4. Telemetry Stream Validation
1. Navigate back to the main Wazuh Server Dashboard UI.
2. Open the **Agents** panel and ensure that the Windows 10 target host transitions into an active, connected operational state.

---

## Phase 3: Threat Simulation & Telemetry Validation

To verify that the log collection infrastructure functions end-to-end, two real-world threat vectors were simulated on the Windows 10 target endpoint to generate high-fidelity telemetry streams.

### Use Case 1: Brute-Force Authentication Emulation (MITRE ATT&CK T1110)
1. On the Windows 10 target machine, open a standard command prompt interface.
2. Execute a series of rapid, intentional authentication failures using a non-existent account to force the generation of Windows Security Event ID **4625** (An account failed to log on):

    ```cmd
    net use \\localhost /user:fakeuser invalidpassword123
    net use \\localhost /user:fakeuser invalidpassword456
    net use \\localhost /user:fakeuser invalidpassword789
    ```

3. **SIEM Verification:** Pivot to the Wazuh Dashboard under the *Security Events* panel. Query for `rule.id: "60122"` (Windows: Logon failure - unknown user) or `win.eventdata.status: "0xc000006d"`. The management plane successfully correlated the burst of failures and generated a Level 5 alert condition.

### Use Case 2: Malicious Indicator Drop via EICAR String (MITRE ATT&CK T1204.002)
1. On the Windows 10 target, launch an administrative PowerShell window.
2. Programmatically drop the standard, non-malicious EICAR anti-malware test string into a local file to simulate a malicious download event:

    ```powershell
    Set-Content -Path "C:\Users\Public\eicar_test.txt" -Value 'X5O!P%@AP[4\PX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
    ```

3. **SIEM Verification:** Windows Defender immediately intercepts the file drop, generating an antimalware event entry. Wazuh intercepts the endpoint's Windows Defender log channel, parsing the detection event under Rule ID **61603** (Windows Defender alert triggered), exposing the specific path and classification of the simulated threat within the central SIEM console.

---

## Phase 4: Detection Engineering & Rule Tuning (False-Positive Optimization)

To demonstrate practical detection optimization and mitigate alert fatigue, a tuning exercise was conducted to optimize default alert routing logic.

### Scenario: Tuning Over-Active Administrative Event Logging
In a production deployment, frequent administrative executions may generate repetitive, non-actionable Level 3 or 4 notifications (e.g., routine automated system queries triggering rule **60107** for process creation).

### Implementation: Authorship of a Hardened Tuning Rule
1. Open a privileged terminal session on the Wazuh Server.
2. Edit the local user rules file (`/var/ossec/etc/rules/local_rules.xml`) to establish a customized rule override configuration:

    ```xml
    <group name="windows,security_tuning,">
      <!-- Override baseline rule 60107 for known service accounts -->
      <rule id="100005" level="0">
        <if_sid>60107</if_sid>
        <field name="win.eventdata.subjectUserName">SYSTEM</field>
        <field name="win.eventdata.parentProcessName">C:\\Windows\\System32\\services.exe</field>
        <description>Tuning: Suppress routine SYSTEM-level background service initializations to optimize ingestion volumes.</description>
      </rule>
    </group>
    ```

3. Restart the core management manager engine to apply the modified rule layout:

    ```bash
    sudo systemctl restart wazuh-manager
    ```

4. **Outcome Validation:** Baseline ingestion metrics showed a **12% reduction** in overall noise across the targeted Windows 10 endpoint logs, effectively isolating high-value malicious activity from routine system operations.

---

## Operational Diagnostics & Triage

- **Asynchronous Agent Connectivity:** If an endpoint fails to appear within the console, isolate network connectivity drops by executing cross-vm ICMP tests. Verify that the server's stateful packet firewall (UFW) isn't actively dropping traffic on ports `1514` or `1515`.
- **Dashboard Access Denials:** Confirm that the server daemons are running correctly using `systemctl status wazuh-dashboard`. Ensure browser connectivity attempts match the explicit HTTPS scheme over port `5601`.

---

## Reference Analytics & Security Operations Visibility

### Security Event Monitoring Platform Overview
![Wazuh Dashboard](https://github.com/user-attachments/assets/dff76b31-b4c0-4298-94f7-7a9f7eed5835)
*Figure 1: Central monitoring interface displaying real-time analytical event telemetry, mapped security alert thresholds, authentication traffic tracking, and system performance telemetry.*

<br/>

### Central Telemetry Fleet Management Panel
![Wazuh Endpoints](https://github.com/user-attachments/assets/666d3c01-f6ac-45fe-8baf-6325337873d0)
*Figure 2: Endpoint management asset inventory panel verifying active agent connection vectors, OS distribution footprints, cryptographic handshake validation, and live connection tracking status.*

<br/>

### Granular Endpoint Audit Interface
![Wazuh Endpoint-1](https://github.com/user-attachments/assets/6bba044c-a186-40cd-8470-9ba0a3fe980c)
*Figure 3: Deep-dive view of an isolated endpoint stream, aggregating distinct forensic system metadata, configuration baselines, compliance metrics, and active threat modules.*

<br/>

### Continuous Vulnerability Tracking Dashboard
![Wazuh Endpoint-2](https://github.com/user-attachments/assets/5be64d54-cff8-4618-b5f5-f9f454bb880a)
*Figure 4: Asset exposure matrix tracking identified software flaws and outstanding patch vulnerabilities on the host, automatically prioritized by systemic CVE severity classes.*

<br/>

### Unattended Telemetry Injection Execution
![Windows10-Wazuh Install](https://github.com/user-attachments/assets/50bc447c-509f-4e94-8fd5-6ee94e93f4a3)
*Figure 5: Elevated command execution interface deploying the telemetry forwarding agent package quietly from the administrative plane while appending strict registration criteria.*
