[![Return to Portfolio](https://img.shields.io/badge/Return%20To-Portfolio%20Homepage-black?style=flat-square&logo=github)](https://github.com/DaPhilll)

# Centralized SIEM/XDR Engineering: Multi-Platform Telemetry Aggregation and Detection Engineering with Wazuh

## 1. Executive Summary & Objective
* **Problem Statement:** Enterprise environments frequently suffer from visibility gaps and alert fatigue due to unoptimized telemetry streams, making it difficult to isolate high-fidelity indicators of compromise from routine system operations.
* **Solution Overview:** This project establishes a complete detection engineering loop by deploying a hardened central Wazuh (v4.11) management plane, configuring automated endpoint telemetry forwarding over an isolated network topology, simulating active adversary behaviors, and authoring custom rule overrides to optimize log ingestion.
* **Core Capabilities:** 
  * Provisioning segmented architecture with stateful transport-layer access controls.
  * Headless administrative deployment of host-based security agents.
  * Behavioral threat simulation mapping to enterprise security event logs.
  * Continuous vulnerability lifecycle assessment and detection logic optimization.

## 2. Architecture & Environment Topology
The infrastructure leverages hardware-level virtualization with discrete layer-2 broadcast domains to simulate an on-premises enterprise environment.

* **Deployment Environment:** Oracle VirtualBox
* **Management Plane:** Ubuntu Server Node (Dedicated 8 GB RAM, localized indexing storage volume)
* **Endpoint Telemetry:** Windows 10 Enterprise (8 GB RAM)
* **Network Design:** Bridged network adapter configuration to ensure independent routing capabilities, restricted by host-based firewalls.
* **SIEM / XDR Core:** Wazuh Manager & Indexer (v4.11) integrated with OpenSearch Dashboards for visualization and analytics querying.

## 3. Engineering Thought Process & Methodology
* **Design Considerations:** A bridged adapter network pattern was implemented to allow direct layer-2 line of sight between the endpoint and the SIEM master node, ensuring authentic transport-layer interaction. Wazuh was selected to demonstrate a unified solution for log aggregation, compliance tracking, and active endpoint detection.
* **Technical Challenges & Resolution:**
  * **Challenge:** High-frequency, routine system process creations triggered default alert rule 60107, resulting in substantial log noise and false-positive inflation within the indexing volume.
  * **Resolution:** Evaluated raw JSON telemetry to identify standard operational baselines. Authored a custom rule override in `local_rules.xml` targeting parent process execution paths for known `SYSTEM` accounts, yielding a 12% reduction in total baseline ingestion noise.

## 4. Cyber Kill Chain & Threat Lifecycle Mapping
This project actively monitors, logs, and triggers alerting mechanisms across the following phases of the Cyber Kill Chain:

* **Delivery:** Simulated malicious indicator delivery via target download methods to validate host-based anti-malware telemetry capture.
* **Actions on Objectives:** Generated rapid, concurrent authentication failures to simulate brute-force credential harvesting and validate multi-event correlation logic.

## 5. MITRE ATT&CK Matrix Alignment
The configurations and adversary emulations built into this project map directly to the following tactics and techniques:

| Tactic | Technique ID | Technique Name | Detection/Mitigation Mechanism |
| :--- | :--- | :--- | :--- |
| **Credential Access** | T1110 | Brute Force | Aggregation of Windows Security Event ID 4625; correlated via Wazuh Rule ID 60122 (Level 5 Alert). |
| **Execution** | T1204.002 | Malicious File | Real-time parsing of Windows Defender Antivirus event channels via Rule ID 61603 to expose payload string paths. |
| **Defense Evasion** | T1562.004 | Disable or Modify System Firewall | Hardening transport layers via stateful host firewalls (UFW and Windows Defender Advanced Security) on port 1514. |

## 6. Telemetry & Vulnerability Intelligence Integrated
* **Tool Name:** Wazuh Vulnerability Detector Engine
  * **Use Case:** Automated software asset inventory auditing to cross-reference installed endpoint application footprints against live CVE indexes.
  * **Artifacts Gathered:** Granular mapping of system vulnerabilities classified by systemic risk ratings and outstanding patch definitions.

## 7. Implementation & Code / Configuration Snippets

### Headless Telemetry Agent Injection (PowerShell)
```powershell
# Programmatically retrieve the verified deployment package from the cloud repository
Invoke-WebRequest -Uri "[https://packages.wazuh.com/4.11/windows/wazuh-agent-4.11-1.msi](https://packages.wazuh.com/4.11/windows/wazuh-agent-4.11-1.msi)" -OutFile "wazuh-agent.msi"

# Execute a silent background installation appending structural management plane criteria
msiexec /i "wazuh-agent.msi" /quiet SERVERIP="<wazuh_server_ip>" SERVERPORT="1514"

# Initialize the telemetry tracking service lifecycle hook
Start-Service WazuhSvc
```

### Detection Engineering: Custom XML Tuning Rule (`/var/ossec/etc/rules/local_rules.xml`)
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

### Stateful Host Network Hardening (Ubuntu Management Plane)
```bash
# Initialize the stateful firewall configuration
sudo ufw enable

# Apply strict transport layer ingress controls for secure infrastructure interaction
sudo ufw allow 1514/udp     # Telemetry Ingestion Vector
sudo ufw allow 1514/tcp     # Telemetry Ingestion Vector
sudo ufw allow 1515/tcp     # Secure Agent Registration Interface
sudo ufw allow 55000/tcp    # Cluster REST API Core Management
sudo ufw allow 9200/tcp     # Underlying Indexer API Loop
sudo ufw allow 5601/tcp     # Cryptographic Web Dashboard UI Access
```

## 8. Operational Verification & Validation (Proof of Concept)

### Use Case 1: Brute-Force Authentication Emulation (T1110)
* **Attack Vector Simulation:** Executed rapid authentication loops using non-existent credentials via the command line interface:
  ```cmd
  net use \\localhost /user:fakeuser invalidpassword123
  ```
* **SIEM Verification:** The management plane successfully correlated the burst of Event ID 4625 entries, parsing the malicious activity and escalating it to a Level 5 security alert under Rule ID 60122.

### Use Case 2: Malicious Indicator Drop via EICAR String (T1204.002)
* **Attack Vector Simulation:** Injected the standard, non-malicious anti-malware test string into local storage using administrative PowerShell:
  ```powershell
  Set-Content -Path "C:\Users\Public\eicar_test.txt" -Value 'X5O!P%@AP[4\PX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
  ```
* **SIEM Verification:** Windows Defender intercepted the file drop. Wazuh instantly ingested the defense event, triggering Rule ID 61603 and exposing the precise file path and signature classification within the OpenSearch console.

## 9. Hardening & Future Enhancements
* **Current Security Posture:** The central manager enforces strict ingress boundary protections using UFW. Telemetry endpoints transmit data over authenticated channels restricted by custom Windows Defender Firewall transport rules.
* **Future Roadmap:**
  * [ ] Configure automated Active Response playbooks to dynamically block adversarial source IPs at the host layer upon reaching brute-force alert thresholds.
  * [ ] Integrate centralized syslog ingestion for edge networking components, specifically focusing on OPNsense firewall routing structures.

---

## Appendix: Reference Analytics & Security Operations Visibility

### Security Event Monitoring Platform Overview
![Wazuh Dashboard](https://github.com/user-attachments/assets/dff76b31-b4c0-4298-94f7-7a9f7eed5835)
*Figure 1: Central monitoring interface displaying real-time analytical event telemetry, mapped security alert thresholds, authentication traffic tracking, and system performance telemetry.*

### Central Telemetry Fleet Management Panel
![Wazuh Endpoints](https://github.com/user-attachments/assets/666d3c01-f6ac-45fe-8baf-6325337873d0)
*Figure 2: Endpoint management asset inventory panel verifying active agent connection vectors, OS distribution footprints, cryptographic handshake validation, and live connection tracking status.*

### Granular Endpoint Audit Interface
![Wazuh Endpoint-1](https://github.com/user-attachments/assets/6bba044c-a186-40cd-8470-9ba0a3fe980c)
*Figure 3: Deep-dive view of an isolated endpoint stream, aggregating distinct forensic system metadata, configuration baselines, compliance metrics, and active threat modules.*

### Continuous Vulnerability Tracking Dashboard
![Wazuh Endpoint-2](https://github.com/user-attachments/assets/5be64d54-cff8-4618-b5f5-f9f454bb880a)
*Figure 4: Asset exposure matrix tracking identified software flaws and outstanding patch vulnerabilities on the host, automatically prioritized by systemic CVE severity classes.*

### Unattended Telemetry Injection Execution
![Windows10-Wazuh Install](https://github.com/user-attachments/assets/50bc447c-509f-4e94-8fd5-6ee94e93f4a3)
*Figure 5: Elevated command execution interface deploying the telemetry forwarding agent package quietly from the administrative plane while appending strict registration criteria.*
