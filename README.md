# Hospital-Record-Analytics-
# SQL project 


## 🔥 Repo Description
Transform complex hospital EHR data into clear insights on revenue leakage, payer performance, and high-risk patient utilization.  
Built entirely in SQL, this project shows how analytics drives financial decisions, care optimization, and operational efficiency.

---

# 🏥 Hospital Record Analytics  
**SQL Analytics Project | Revenue Integrity • Utilization • Population Health**

---

## 📌 Project Overview
This project analyzes electronic health record (EHR) data to answer critical questions for:
- 💰 Revenue Cycle teams  
- 🏥 Hospital Operations  
- 🧑‍⚕️ Clinical & Population Health leaders  

Using SQL Server, the analysis transforms raw transactional data into insights on:
- Revenue performance  
- Payer efficiency  
- Patient utilization  
- Data integrity  

---

## 🎯 Objective
Convert complex hospital data into actionable insights that improve:
- Financial performance  
- Clinical outcomes  
- Operational efficiency  

---

## 🚀 Key Business Goals
- ✅ Validate data integrity across all tables  
- 💵 Measure revenue, coverage %, and payer performance  
- 📊 Identify high-cost services and common diagnoses  
- 🧍 Profile patient utilization and demographics  
- 🚨 Detect revenue leakage and underbilling  
- 🏆 Identify top 1% high-cost “super-utilizers”  
- 📈 Track monthly performance trends (Revenue, ALOS, Collections)

---

## 🧠 Skills Demonstrated

| Category | Skills |
|----------|--------|
| **SQL Server** | CTEs, Multi-table Joins, Window Functions (`LAG`, `NTILE`, `SUM() OVER`), Date Functions |
| **Healthcare Analytics** | Revenue Cycle KPIs, ALOS, Payer Mix, High-Utilizer Detection |
| **Analytics** | Cohort Trends, Outlier Detection, Percentile Ranking |
| **Data Quality** | Orphan Record Checks, NULL Handling, Join Validation |
| **Business Thinking** | Revenue Leakage Detection, Contract Negotiation Support |

---

## 🗂️ Data Overview

### 🧩 Tables Used

#### 1️⃣ `encounters` (Fact Table)
- One row per hospital visit  
- Includes billing, payer, and encounter details  

#### 2️⃣ `patients` (Dimension)
- Patient demographics and location  

#### 3️⃣ `payer` (Dimension)
- Insurance provider details  

#### 4️⃣ `procedures` (Fact Table)
- Line-level procedures tied to encounters  

**Relationships:**
- `patients.id` → `encounters.patient`  
- `encounters.id` → `procedures.encounter`  
- `payer.id` → `encounters.payer`  

---

## ⚙️ Data Transformation Highlights
- 🎂 Age calculation using `DATEDIFF`  
- 🏥 Length of Stay (ALOS) from encounter timestamps  
- 📆 Monthly trends via `DATEFROMPARTS`  
- 💰 Coverage % = payer contribution vs total cost  
- 📊 Utilization ranking using `NTILE(100)`  
- 🚨 Revenue integrity check (procedures vs encounter cost)  

---


---

## 📊 Business Questions Answered

| # | Business Question | Method |
|---|------------------|--------|
| 1 | Are there missing links in the data? | Orphan checks via `LEFT JOIN` |
| 2 | Which services drive revenue? | Revenue & coverage by encounter type |
| 3 | What diagnoses cost the most? | Volume + cost aggregation |
| 4 | Who uses the hospital most? | Demographic segmentation |
| 5 | Which payers perform best? | Coverage % + patient responsibility |
| 6 | Is revenue being lost? | Procedure vs encounter cost validation |
| 7 | Who are high-cost patients? | Top 1% via `NTILE(100)` |
| 8 | Are we improving over time? | Monthly trends with `LAG` |

---

## 💡 Key Insights & Recommendations

- 🚨 1.8% encounters missing patients → Fix ETL or exclude from reports  
- 💰 Inpatient = 68% revenue but 79% coverage → renegotiate payer contracts  
- 🧠 Sepsis & Acute MI = 31% cost → implement care pathways  
- 📉 Low-performing payer → high patient burden → renegotiate terms  
- 💸 $3.2k avg surgical revenue gap → audit charge capture  
- 🏆 Top 100 patients = $9.1M spend → care management can save ~$800k  
- 📊 Collection rate dropped 86% → 81% → investigate billing issues  

---

## 🧾 Conclusion
This project demonstrates how SQL can transform complex healthcare data into financial and clinical insights that drive real-world decisions.

---  


---

## 👤 Author
**Yakubu Hamza Ugbedeojo**  
📧 mailx0hamza@gmail.com  
