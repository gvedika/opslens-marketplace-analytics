# OpsLens — Business Recommendation Framework

## Recommendation 1: Customer Retention Crisis
**Issue:** 97% of customers are one-time buyers (98,199 orders ≈ 98,199 unique customers)
**Evidence:** RFM segmentation shows near-zero "Repeat Customer" volume; 24,340 customers are "At Risk (High Value)"
**Business Impact:** Acquisition cost is paid repeatedly with no compounding return
**Priority:** Critical
**Recommended Action:** Post-purchase retention campaign targeting the 24,340 At-Risk high-value customers first
**Expected Benefit:** Even 5% conversion adds ~1,200 recurring customers, improving LTV per acquisition dollar

## Recommendation 2: Northeast Brazil Delivery Crisis
**Issue:** AL, MA, PI, CE, SE show 15–24% late delivery vs. 5.9% in SP
**Evidence:** Avg delivery time 19–24 days in these states vs. 8 days in SP, driven by distance from seller concentration
**Business Impact:** Regional customers get a fundamentally worse experience, risking review/reputation damage
**Priority:** High
**Recommended Action:** Regional fulfillment partnerships or more realistic estimated delivery dates for these states
**Expected Benefit:** Halving late rate in worst 5 states improves experience for 2,000+ annual orders

## Recommendation 3: Seasonal Logistics Strain
**Issue:** Late delivery spiked to 13.84% (Nov 2017) and 20.47% (Mar 2018)
**Evidence:** Monthly Marketplace Health Score dips during these exact months despite revenue growth
**Business Impact:** Demand surges overwhelm logistics precisely when order visibility is highest
**Priority:** High
**Recommended Action:** Pre-negotiate seasonal carrier capacity ahead of known high-volume periods
**Expected Benefit:** Prevents recurring health-score dips during peak revenue months

## Recommendation 4: High-Risk Seller Intervention
**Issue:** 149 sellers (4.9%) fall into "High Risk" health category
**Evidence:** Seller Health Score formula flags low revenue + poor reviews + high late-delivery combination
**Business Impact:** Disproportionately drags down marketplace-wide trust and review scores
**Priority:** Medium-High
**Recommended Action:** Seller improvement program — automated alerts, probation period, visibility reduction if unresolved
**Expected Benefit:** Protects the platform's 4.09 average review score from erosion

## Recommendation 5: Excellent Seller Visibility Opportunity
**Issue:** Only 86 sellers (2.8%) qualify as "Excellent" despite strong metrics
**Evidence:** Top sellers show 0% late delivery, near-perfect reviews, but moderate order volume
**Business Impact:** Best-performing partners are underexposed relative to their quality
**Priority:** Medium
**Recommended Action:** Search ranking boosts, "Top Rated Seller" badges, category spotlight placements
**Expected Benefit:** 15-20% order volume increase for top-tier sellers reinforces a positive quality loop

## Recommendation 6: Holiday Revenue Concentration Risk
**Issue:** Nov 2017 revenue grew 52% MoM, then fell -26% in Dec 2017
**Evidence:** SQL window function (LAG) analysis of monthly revenue trend
**Business Impact:** Heavy seasonal reliance creates unpredictable operational load and forecasting difficulty
**Priority:** Medium
**Recommended Action:** Off-season promotional campaigns to smooth demand across the calendar year
**Expected Benefit:** More predictable operations; reduces logistics strain tied to Recommendation 3

## Recommendation 7: Product Category Data Gaps
**Issue:** 610 products (1.9% of catalog) had missing category data
**Evidence:** Identified during Phase 1 data cleaning (`product_category_name` nulls)
**Business Impact:** Uncategorized products are harder to discover via search/browse, suppressing sales potential
**Priority:** Low-Medium
**Recommended Action:** Make category selection mandatory at listing time; audit existing uncategorized products
**Expected Benefit:** Improved discoverability for currently "invisible" inventory

## Recommendation 8: Credit Card Dependency & Installment Risk
**Issue:** Credit card is the dominant payment method (76,795 payments, 74% of volume), averaging 3 installments per transaction
**Evidence:** Payment analysis shows credit card AOV (R$163.32) is notably higher than boleto (R$145.03) or voucher (R$65.70) — customers spend more when installments are available, but this creates payment-completion risk if a customer's card declines mid-installment
**Business Impact:** Heavy reliance on a single payment method with deferred completion (installments) exposes revenue to payment-failure risk not present in single-payment methods like boleto
**Priority:** Medium
**Recommended Action:** Ensure boleto and debit card remain fully supported as resilient alternatives; monitor installment default/failure rates if that data becomes available
**Expected Benefit:** Protects against over-concentration risk in one payment method while preserving the AOV lift installments provide

## Recommendation 9: Geographic Expansion Opportunity
**Issue:** Several mid-tier states (PR, SC, GO, DF) show high revenue-per-seller (R$300–550) combined with strong review scores (4.0–4.2), despite lower seller counts than SP
**Evidence:** State-level analysis of revenue-per-seller alongside average review score identifies markets with strong demand relative to seller supply
**Business Impact:** These states show demand is being served well by relatively few sellers — signals of an underserved, high-quality market ripe for seller recruitment
**Priority:** Medium
**Recommended Action:** Prioritize seller acquisition campaigns in PR, SC, GO, and DF, where customer satisfaction is already high and competition per seller is comparatively low
**Expected Benefit:** Expanding seller base in high-performing, under-saturated states can capture additional demand without diluting existing service quality

## Recommendation 10: Review Response Time Has Minimal Score Impact
**Issue:** Average seller response time to reviews is nearly identical across all review scores (70–76 hours), regardless of whether the review was 1-star or 5-star
**Evidence:** Response time analysis shows no meaningful correlation between response speed and review score (5-star: 76 hrs avg; 1-star: 72 hrs avg)
**Business Impact:** This suggests review scores are driven by product/delivery experience, not by how quickly sellers respond — response time is not currently a lever for improving satisfaction
**Priority:** Low
**Recommended Action:** Deprioritize response-time-based seller interventions; focus improvement efforts on delivery reliability and product quality instead (per Recommendations 2-4)
**Expected Benefit:** Redirects operational focus toward higher-impact areas rather than a metric with limited influence on outcomes