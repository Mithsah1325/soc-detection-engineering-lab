# SIEM Configuration Guide

This folder contains baseline configuration to run the SOC lab with Elastic Stack.

## Files

- `elasticsearch_config.yml` - Elasticsearch single-node lab configuration.
- `logstash_pipeline.conf` - Logstash pipeline for Linux system logs and custom SOC logs.
- `kibana_visualization_guide.md` - Dashboard creation guide.

## 1) Configure Elasticsearch

1. Copy `elasticsearch_config.yml` values into your local `elasticsearch.yml`.
2. Start Elasticsearch and verify:

```bash
curl http://localhost:9200
```

## 2) Configure Logstash

Run Logstash with the provided pipeline:

```bash
logstash -f SIEM-Config/logstash_pipeline.conf
```

## 3) Validate Ingestion

After running attack simulations, verify data is indexed:

```bash
curl "http://localhost:9200/soc-logs-*/_search?pretty"
```

## 4) Build Kibana Visualizations

Follow `kibana_visualization_guide.md` to build visualizations and detection dashboards.