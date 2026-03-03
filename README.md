# SOC Analyst Project

A hands-on Security Operations Center (SOC) lab project for threat simulation, detection engineering, SIEM ingestion, and basic automated response.

## What this project includes

- **Attack simulations** for:
  - Brute-force behavior
  - Suspicious process behavior (PowerShell encoded command pattern)
  - Data exfiltration-style HTTP POST
- **Sigma rules** for:
  - Brute-force login attempts
  - Suspicious process creation patterns
  - Suspicious DNS queries
- **Automation scripts** for blocking malicious IPs on:
  - Linux (`iptables`)
  - Windows (`NetFirewallRule`)
- **SIEM configs** for Elastic Stack:
  - Elasticsearch lab configuration
  - Logstash pipeline for common Linux + SOC simulation logs
- **Documentation** for setup and reporting

## Repository structure

```text
SOC-Analyst-Project-main/
├── Attack-Simulations/
│   ├── brute_force_attack.sh
│   ├── exfiltration_attack.sh
│   └── process_injection_attack.ps1
├── Automation-Scripts/
│   ├── block_ip.sh
│   └── block_ip.ps1
├── Documentation/
│   ├── README.md
│   ├── full info.md
│   └── project_report.md
├── SIEM-Config/
│   ├── elasticsearch_config.yml
│   ├── kibana_visualization_guide.md
│   ├── logstash_pipeline.conf
│   └── README.md
├── Sigma-Rules/
│   ├── brute_force.yml
│   ├── process_injection.yml
│   └── suspicious_dns_queries.yml
├── LICENSE
└── README.md
```

## Prerequisites

### Core

- Elasticsearch
- Logstash
- Kibana

### Linux simulations/automation

- `bash`
- `curl`
- `hydra` (for brute-force simulation)
- `iptables` (for response script)

### Windows simulation/automation

- PowerShell 5.1+
- Administrative shell for firewall rule changes

## Quick start

### 1) Clone

```bash
git clone https://github.com/Cipherkrish69x/SOC-Analyst-Project.git
cd SOC-Analyst-Project
```

### 2) Configure Elastic Stack

- Apply settings from `SIEM-Config/elasticsearch_config.yml` to your `elasticsearch.yml`.
- Run Logstash using:

```bash
logstash -f SIEM-Config/logstash_pipeline.conf
```

- Open Kibana and create an index pattern for:

```text
soc-logs-*
```

### 3) Run simulations

#### Linux brute-force simulation

```bash
bash Attack-Simulations/brute_force_attack.sh <target_ip> <username> <wordlist_path> [service]
```

Example:

```bash
bash Attack-Simulations/brute_force_attack.sh 192.168.1.20 admin /usr/share/wordlists/rockyou.txt ssh
```

#### Linux exfiltration simulation

```bash
bash Attack-Simulations/exfiltration_attack.sh <sensitive_file_path> <endpoint_url>
```

Example:

```bash
bash Attack-Simulations/exfiltration_attack.sh ./sample_data.txt http://127.0.0.1:8080/exfiltrate
```

#### Windows process-behavior simulation

```powershell
powershell -ExecutionPolicy Bypass -File .\Attack-Simulations\process_injection_attack.ps1
```

### 4) Test automated response

#### Linux

```bash
sudo bash Automation-Scripts/block_ip.sh 192.168.1.101
```

#### Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\Automation-Scripts\block_ip.ps1 -IpAddress 192.168.1.101
```

### 5) Validate SIEM ingestion

```bash
curl "http://localhost:9200/soc-logs-*/_search?pretty"
```

Then build dashboards using `SIEM-Config/kibana_visualization_guide.md`.

## Sigma rules and mapping

- `Sigma-Rules/brute_force.yml` → MITRE ATT&CK `T1110`
- `Sigma-Rules/process_injection.yml` → suspicious encoded PowerShell process behavior
- `Sigma-Rules/suspicious_dns_queries.yml` → MITRE ATT&CK `T1071.004`

## Continuous improvement (CI + QA)

This project includes a CI pipeline at `.github/workflows/ci.yml` that runs on every push/PR.

### What CI validates

- Script quality gates (`tools/check_scripts.py`):
  - Bash scripts include strict mode and shebang.
  - PowerShell scripts use strict error handling.
- Detection QA (`tools/test_detections.py`):
  - Sigma files contain required fields.
  - Test events in `tests/data/events.jsonl` trigger expected Sigma rules.

### Run checks locally

```bash
python -m pip install -r requirements-dev.txt
python tools/check_scripts.py
python tools/test_detections.py
```

### Why this matters for SOC maturity

- Reduces broken detections from being merged.
- Makes detection behavior testable and repeatable.
- Demonstrates continuous improvement beyond monitoring.

## Notes

- This repository is designed as a **training/lab SOC project**, not a production SOC platform.
- Some simulations can be noisy. Run only in an isolated lab environment.


## License

MIT License (see `LICENSE`).
