# Smart Manufacturing – Production Line Condition Monitoring
**Azure Databricks · Delta Live Tables · Medallion Architecture**

## Project Overview

This project implements an industrial IoT streaming pipeline for monitoring the health and performance of a production line. Using Azure Databricks, Delta Live Tables (DLT), and the Medallion Architecture, the pipeline ingests simulated sensor data from six critical machines, validates and enriches it, and produces **analytics-ready metrics** for condition monitoring, predictive maintenance, and operational insight.  

Each device emits continuous streaming data in Delta format, with event timestamps and randomized, realistic values.

---

## Objectives

1. **Simulate industrial IoT data** for a small production line with six critical machines.  
2. **Ingest raw sensor streams** into a Bronze layer using DLT streaming pipelines.  
3. **Validate, normalize, and enrich data** in the Silver layer, adding machine metadata.  
4. **Aggregate and compute actionable metrics** in the Gold layer (10-minute tumbling windows).  
5. **Demonstrate production-grade streaming ETL patterns** on Databricks (as of Dec 2025).  

---

## Architecture

The streaming pipeline follows a **Medallion architecture**, consisting of three main layers plus data generation and consumption:

| Layer / Stage                   | Description                                                                                  | Output / Purpose                               |
|---------------------------------|----------------------------------------------------------------------------------------------|------------------------------------------------|
| **IoT Sensor Stream Generator**  | Simulates industrial IoT sensor streams for six machines; generates raw event data.        | Continuous Delta files with timestamped events |
| **00_landing (Delta files)**     | Raw landing area for all sensor streams before processing.                                   | Raw Delta tables per sensor type              |
| **Bronze Layer**                 | Raw streaming ingestion using Delta Live Tables; preserves original sensor events.          | Bronze tables per sensor type; no transformations |
| **Silver Layer**                 | Validates and enriches streams using DLT expectations and machine metadata.                 | Analytics-ready Silver tables; cleaned and enriched |
| **Gold Layer**                   | Aggregates data per machine into time windows (avg, max, min) and prepares metrics.         | Gold tables for dashboards, alerts, and analytics |
| **Dashboards / Alerts / BI**     | Consumption layer for monitoring and decision-making; can integrate with Databricks SQL or BI tools. | Visualizations and operational insights       |

---

## Production Line Machines and Sensors

| Machine ID | Machine Name                | Sensor Type(s)            | Measurement Unit | Realistic Value Range        | Notes / Purpose |
|------------|----------------------------|--------------------------|----------------|-----------------------------|----------------|
| 1          | Main Drive Motor           | Temperature, Vibration, Power Consumption | °C, g, kW      | Temp: 40–90°C<br>Vib: 0–0.08 g<br>Power: 10–50 kW | Critical motor; vibration indicates bearing health; power for load monitoring |
| 2          | Conveyor Belt Motor        | Temperature, Vibration, Belt Speed         | °C, g, m/s     | Temp: 35–75°C<br>Vib: 0–0.05 g<br>Speed: 0.5–2.5 m/s | Conveyor belt operation; vibration for misalignment; speed for throughput |
| 3          | Hydraulic Press            | Temperature, Pressure, Cycle Count         | °C, bar, cycles| Temp: 40–85°C<br>Pressure: 100–300 bar<br>Cycles: 0–60 per min | High-pressure system; pressure ensures safety; cycles for workload monitoring |
| 4          | CNC Spindle                | Temperature, Vibration, RPM                | °C, g, RPM     | Temp: 35–80°C<br>Vib: 0–0.06 g<br>RPM: 500–5000 | Rotational tool; vibration indicates wear; RPM for speed control |
| 5          | Cooling System Pump        | Temperature, Flow Rate                      | °C, L/min      | Temp: 20–60°C<br>Flow: 50–200 L/min | Keeps equipment within safe operating temperature |
| 6          | Packaging Unit Motor       | Temperature, Vibration, Motor Current      | °C, g, A       | Temp: 30–70°C<br>Vib: 0–0.05 g<br>Current: 5–20 A | Drives packaging mechanism; vibration and current indicate mechanical load |

---

## Data Generation Strategy

- **Streaming simulation** using Python and Spark.  
- Each machine emits sensor readings every **60 seconds** with slight randomized latency.  
- Event timestamps (`event_time`) are slightly randomized to simulate realistic IoT conditions.  
- Multiple metrics per machine can be handled in separate Delta tables or combined streams.  
- The generator supports **parallel streams** for all machines simultaneously.  

---

## Bronze Layer

**Notebook:** `01_bronze_processing`  

- Raw sensor ingestion from Delta streams.  
- Separate Bronze tables per sensor type:
  - `main_motor_temperature`
  - `main_motor_vibration`
  - `main_motor_power`  
  - ... (similar tables for each machine and sensor)
- Preserves original event timestamps and values.  

---

## Silver Layer

**Notebook:** `02_silver_processing`  

- Applies **DLT expectations** for:
  - Non-null `event_time`  
  - Valid sensor value ranges (as in the table above)  
- Normalizes schemas (`timestamp`, `machine_id`)  
- Enriches events with **static machine metadata**:
  - Machine name  
  - Type / location / line section  
- Prepares data for analytics-ready aggregations.  

---

## Gold Layer

**Notebook:** `03_gold_processing`  

- Aggregates data into **10-minute tumbling windows** per machine:  
  - Average temperature  
  - Maximum vibration  
  - Maximum load / pressure / flow / current as appropriate  
- Uses **event-time processing** with 2-minute watermarks  
- Joins multiple sensor streams for a single machine into one analytics-ready record  
- Ready for:
  - Dashboards  
  - Alerting (threshold breaches)  
  - Predictive maintenance analytics  

---

## Key Design Principles

- **Medallion architecture**: Bronze → Silver → Gold  
- **Data quality as code** with DLT expectations  
- **Event-time correctness** and watermarking  
- **Production-grade streaming** using Databricks ETL pipelines  
- **Extensible and modular**: easy to add new machines or sensors  

---

## Possible Extensions

- **Anomaly detection** using vibration and temperature trends  
- **Predictive maintenance alerts** when thresholds are exceeded  
- **Integration with factory MES / SCADA systems**  
- **Historical analysis and KPI dashboards**  

---

## Author

tauimonen  
Azure Databricks · Data Engineering · Streaming Analytics
