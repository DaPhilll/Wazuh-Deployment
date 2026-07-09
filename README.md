[![Darreon Phillips Homepage](https://img.shields.io/badge/Darreon%20Phillips-Homepage-blue?style=for-the-badge&logo=github&logoColor=white)](https://github.com/DaPhilll)

# Centralized SIEM/XDR: Multi-Platform Telemetry Aggregation and Detection Engineering with Wazuh

## Repository Structure
```
/scripts
  deploy-agent.ps1
  harden-manager.sh
/rules
  local_rules.xml
LICENSE
README.md
```

## 1. Executive Summary & Objective
* **Problem Statement:** Enterprise environments suffer from visibility gaps and alert fatigue when telemetry streams go untuned, making it hard to separate high-fidelity indicators of compromise from routine system activity.
* **Solution Overview:** This project builds a full detection engineering loop: a central Wazuh (v4.11) management plane, automated endpoint telemetry forwarding across an isolated network, simulated adversary behavior, and custom rule overrides to reduce ingestion noise.
* **Core Capabilities:**
  * Segmented network architecture with stateful transport-layer access controls.
  * Headless deployment of host-based security agents.
  * Behavioral threat simulation mapped to Windows security event logs.
  * Continuous vulnerability assessment and detection logic tuning.

## 2. Architecture & Environment Topology
The lab runs on VMware Workstation Pro, using a bridged network segment to model a small enterprise network. This same environment is reused across the related detection, SOAR, IDS, and vulnerability management projects.

* **Deployment Environment:** VMware Workstation Pro
* **Network Segment:** `10.10.0.0/24` (bridged adapter, host-firewall restricted)
* **Management Plane:** Ubuntu Server — `SRV-SOC01` (8 GB RAM, local indexing volume)
* **Endpoint:** Windows 10 Enterprise — `WKSTN-01` (8 GB RAM)
* **Domain Controller:** Windows Server — `SRV-DC01`
* **SIEM/XDR Core:** Wazuh Manager & Indexer (v4.11) with OpenSearch Dashboards

## 3. Engineering Thought Process & Methodology
* **Design Considerations:** A bridged adapter puts the endpoints and the Wazuh manager on the same network segment, so agent traffic behaves the way it would on a physical LAN. Wazuh was selected as a unified platform for log aggregation, compliance tracking, and active endpoint detection.
* **Technical Challenges & Resolution:**
  * **Challenge:** High-frequency routine process creation triggered default rule 60107, inflating log volume with false positives.
  * **Resolution:** Analyzed raw JSON telemetry to establish an operational baseline, then authored a custom override in `local_rules.xml` targeting parent process paths for known `SYSTEM` accounts, reducing baseline ingestion noise in the lab environment.

## 4. Cyber Kill Chain & Threat Lifecycle Mapping
* **Delivery:** Simulated malicious indicator delivery via download methods to validate host anti-malware telemetry capture.
* **Actions on Objectives:** Generated concurrent authentication failures to simulate brute-force credential access and validate multi-event correlation.

## 5. MITRE ATT&CK Matrix Alignment

| Tactic | Technique ID | Technique Name | Detection Mechanism |
| :--- | :--- | :--- | :--- |
| **Credential Access** | T1110 | Brute Force | Aggregation of Windows Event ID 4625, correlated via Wazuh Rule ID 60122 (Level 5). |
| **Execution** | T1204.002 | Malicious File | Parsing Windows Defender event channels via Rule ID 61603 to expose payload paths. |
| **Defense Evasion** | T1562.004 | Disable or Modify System Firewall | Stateful host firewalls (UFW, Windows Defender Firewall) enforced on port 1514. |

## 6. Telemetry & Vulnerability Intelligence Integrated
* **Wazuh Vulnerability Detector:** Automated software inventory auditing that cross-references installed endpoint applications against CVE indexes, classifying findings by risk rating and outstanding patch state.

## 7. Implementation & Configuration

### Headless Agent Deployment
`scripts/deploy-agent.ps1`
```powershell
# Retrieve the deployment package
Invoke-WebRequest -Uri "https://packages.wazuh.com/4.11/windows/wazuh-agent-4.11-1.msi" -OutFile "wazuh-agent.msi"

# Silent install with management plane parameters
msiexec /i "wazuh-agent.msi" /quiet SERVERIP="10.10.0.10" SERVERPORT="1514"

# Start the agent service
Start-Service WazuhSvc
```

### Custom Tuning Rule
`rules/local_rules.xml` (deployed to `/var/ossec/etc/rules/local_rules.xml`)
```xml
<group name="windows,security_tuning,">
  <!-- Override baseline rule 60107 for known service accounts -->
  <rule id="100005" level="0">
    <if_sid>60107</if_sid>
    <field name="win.eventdata.subjectUserName">SYSTEM</field>
    <field name="win.eventdata.parentProcessName">C:\\Windows\\System32\\services.exe</field>
    <description>Tuning: Suppress routine SYSTEM-level service initializations to reduce ingestion volume.</description>
  </rule>
</group>
```

### Host Network Hardening
`scripts/harden-manager.sh`
```bash
sudo ufw enable
sudo ufw allow 1514/udp     # Telemetry ingestion
sudo ufw allow 1514/tcp     # Telemetry ingestion
sudo ufw allow 1515/tcp     # Agent registration
sudo ufw allow 55000/tcp    # REST API management
sudo ufw allow 9200/tcp     # Indexer API
sudo ufw allow 5601/tcp     # Web dashboard
```

## 8. Operational Verification & Validation

### Use Case 1: Brute-Force Authentication (T1110)
* **Simulation:** Executed rapid authentication attempts with invalid credentials:
  ```cmd
  net use \\localhost /user:fakeuser invalidpassword123
  ```
* **Verification:** The manager correlated the burst of Event ID 4625 entries and escalated to a Level 5 alert under Rule ID 60122.

### Use Case 2: Malicious Indicator Drop via EICAR (T1204.002)
* **Simulation:** Wrote the standard EICAR anti-malware test string to local storage:
  ```powershell
  Set-Content -Path "C:\Users\Public\eicar_test.txt" -Value 'X5O!P%@AP[4\PX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
  ```
* **Verification:** Windows Defender intercepted the file. Wazuh ingested the defense event, triggered Rule ID 61603, and surfaced the file path and signature classification in OpenSearch.

## 9. Hardening & Future Enhancements
* **Current Posture:** The manager enforces ingress boundaries with UFW. Endpoints transmit over authenticated channels restricted by Windows Defender Firewall rules.
* **Future Roadmap:**
  * [ ] Configure Active Response playbooks to block source IPs at the host layer on brute-force thresholds.
  * [ ] Integrate syslog ingestion for edge networking components (OPNsense).

## License
MIT — see [LICENSE](./LICENSE).

---

## Appendix: Deployment Screenshots

### Wazuh Overview Dashboard
![Wazuh Dashboard](https://github.com/user-attachments/assets/dff76b31-b4c0-4298-94f7-7a9f7eed5835)
*Figure 1: The main Wazuh dashboard showing event volume, alert severity levels, authentication activity, and system performance.*

### Agent Management
![Wazuh Endpoints](https://github.com/user-attachments/assets/666d3c01-f6ac-45fe-8baf-6325337873d0)
*Figure 2: The agent inventory showing connected endpoints, their operating systems, and current connection status.*

### Endpoint Detail View
![Wazuh Endpoint-1](https://github.com/user-attachments/assets/6bba044c-a186-40cd-8470-9ba0a3fe980c)
*Figure 3: Detail view for a single endpoint, including system metadata, configuration baseline, and compliance status.*

### Vulnerability Detection
![Wazuh Endpoint-2](https://github.com/user-attachments/assets/5be64d54-cff8-4618-b5f5-f9f454bb880a)
*Figure 4: Vulnerability findings for the endpoint, prioritized by CVE severity and patch status.*

### Silent Agent Installation
![Windows10-Wazuh Install](https://github.com/user-attachments/assets/50bc447c-509f-4e94-8fd5-6ee94e93f4a3)
*Figure 5: The silent agent install running from an elevated prompt on the Windows endpoint, with the manager IP and port passed as install parameters.*

<br><br><br>
[![Darreon Phillips Homepage](https://img.shields.io/badge/Darreon%20Phillips-Homepage-blue?style=for-the-badge&logo=github&logoColor=white)](https://github.com/DaPhilll)
