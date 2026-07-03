# OpsLens — KPI Dictionary

## Core Marketplace Metrics

| KPI | Formula | Business Meaning |
|---|---|---|
| Total Revenue | SUM(order_item price) | Gross merchandise value, excludes freight |
| Total Orders | COUNT(DISTINCT order_id), excluding canceled/unavailable | Completed order volume |
| Average Order Value (AOV) | Total Revenue / Total Orders | Spending per transaction |
| Active Customers | COUNT(DISTINCT customer_id) | Unique buyers in period |
| Active Sellers | COUNT(DISTINCT seller_id) with ≥1 order | Sellers generating revenue |
| Delivery Completion Rate | % of orders with delivered_customer_date populated | Fulfillment reliability |
| Late Delivery Rate | % of delivered orders where actual date > estimated date | SLA breach rate |
| Average Review Score | AVG(review_score), scale 1–5 | Customer satisfaction |

## Seller Health Score

**Formula:** `(Revenue Quartile × 0.3) + (Review Score Quartile × 0.4) + (Delivery Reliability Quartile × 0.3)`

- Each seller is scored 1–4 (quartile) on: total revenue, average review score, and late delivery rate (inverted — lower late % = higher score)
- Review score weighted highest (0.4) since customer satisfaction is the strongest predictor of marketplace trust
- **Categories:** Excellent (≥3.5) · Stable (2.5–3.49) · Watchlist (1.5–2.49) · High Risk (<1.5)

## Customer RFM Segmentation

- **Recency:** Days since last order (quartile-scored, most recent = highest score)
- **Frequency:** Number of distinct orders (used directly — not quartiled, since ~97% of customers have frequency = 1)
- **Monetary:** Total customer spend (quartile-scored)

**Segments:**
| Segment | Definition |
|---|---|
| Repeat Customer | frequency ≥ 2 |
| High-Value New | Recent + high spend, first-time |
| Recent Customer | Recent, moderate/low spend |
| At Risk (High Value) | Not recent, but historically high spend |
| Lapsed | Not recent, low spend |
| Regular | Everything else |

## Marketplace Health Score

**Formula:** `(Revenue Quartile × 0.3) + (Review Score Quartile × 0.3) + (Delivery Completion Quartile × 0.2) + (Late Rate Quartile × 0.2)`

Calculated monthly. Composite executive metric combining growth, satisfaction, and operational reliability into a single trackable number.

## Data Notes / Known Limitations

- 2016 data (Sep–Dec) excluded from trend analysis — pilot phase, negligible volume (<300 orders total)
- Sep 2018 is a partial month (dataset cutoff) — excluded from health score trending
- "Repeat Customer" segment is small (~3% of base) — reflects genuinely low platform-wide repeat purchase behavior, not a data error