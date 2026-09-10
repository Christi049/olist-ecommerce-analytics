# Olist E-Commerce Analytics — Business Insights & Recommendations

**Project scope:** ~99,441 orders, Sept 2016 – Aug 2018, Brazilian e-commerce marketplace.
**Analysis stack:** MySQL (business queries), Python/pandas (EDA, statistical validation), Streamlit (dashboard).

---

## Headline Finding: Delivery Delay Is the Strongest Driver of Customer Dissatisfaction

**The finding:** Orders delivered late average a **2.27/5** review score. Orders delivered on-time or early average **4.29/5** — nearly double.

**Statistical validation:** Welch's t-test on 95,607 delivered-and-reviewed orders (late n=6,360, on-time n=89,247): **t = -100.76, p < 0.001**. This is not sampling noise — it is one of the strongest effects in the dataset.

**Supporting evidence (cross-validated three ways):**
- By category: `office_furniture` has both the longest average delivery time (20.4 days) and the lowest average review score (3.52) of any major category.
- By state: the states with the highest late-delivery rates (`AL` 21.4%, `MA` 17.4%, `SE` 15.2%) are the same states with the lowest average review scores (`AL` 3.86, `MA` 3.83, `SE` 3.90). The most reliable states (`SP`, `MG`, `PR`) also have the highest review scores.
- Correlation: `delivery_delay_days` vs `review_score` = -0.27 (moderate, continuous relationship), while the t-test shows a sharper threshold/cliff effect once an order crosses into "late."

**Stakeholder:** Operations / Logistics lead; Customer Experience lead.

**Recommendation:** Treat on-time delivery as the primary lever for review-score and (indirectly) retention improvement — ahead of pricing or product-catalog changes. Prioritize the two root causes identified below over generic "improve logistics" initiatives.

---

## Finding 2: Delivery Delay Has Two Distinct, Separable Root Causes

### 2a — A specific São Paulo → Rio de Janeiro shipping corridor problem

Rio de Janeiro customers show a 12.11% late-delivery rate — notably worse than other major, well-connected states. Breaking this down by seller origin:
- Orders shipped from **SP-based sellers to RJ customers**: 13.50% late (9,403 of ~12,350 RJ orders)
- Orders shipped from **RJ-based sellers to RJ customers**: 4.52% late — in line with SP's own strong in-state performance (4.49%)

**Conclusion:** RJ's problem is not "Rio is hard to deliver to." It is a specific SP→RJ logistics lane underperforming, while local RJ fulfillment is healthy.

**Stakeholder:** Logistics/Carrier management.
**Recommendation:** Audit carrier performance specifically on the SP→RJ route; consider a carrier review or renegotiation targeted at this lane rather than a blanket logistics overhaul.

### 2b — A tail of chronically underperforming individual sellers

A small number of sellers show late-delivery rates of 20-50%, far above the 6.77% platform-wide average — and they are **not geographically concentrated** (found in SP, PR, MG, SC). Example: one seller with 46 orders has a 50.00% late rate.

**Stakeholder:** Seller Operations / Marketplace Quality team.
**Recommendation:** Implement a seller-performance audit for any seller with >20% late-delivery rate and ≥30 orders. This is a concrete, executable screening rule, not a vague "monitor sellers" directive.

---

## Finding 3: Revenue Is Heavily Concentrated in a Minority of High-Value, One-Time Customers

**Customer segmentation** (built on Recency/Monetary value — standard RFM's Frequency dimension had to be adapted, see Finding 4):

| Segment | Customers | Revenue | Avg Value | Avg Recency |
|---|---|---|---|---|
| Recent High-Value | 14,099 | $4.99M | $353.62 | 121.5 days |
| Lapsed High-Value | 11,304 | $4.11M | $363.22 | 377.6 days |
| Recent Low-Value | 35,361 | $2.97M | $84.05 | 121.5 days |
| Lapsed Low-Value | 29,793 | $2.49M | $83.65 | 378.6 days |
| Loyal / Repeat | 2,801 | $0.86M | $308.53 | 219.8 days |

**The finding:** High-Value segments (Recent + Lapsed) are only ~27% of the customer base but drive over 60% of total revenue.

**Stakeholder:** Retention / CRM lead; Marketing.

**Recommendation:** The **Lapsed High-Value** segment (11,304 customers, $4.1M in historical spend, dormant ~1 year on average) is the single highest-leverage re-engagement target on the platform. A targeted win-back campaign (email, discount incentive) aimed specifically at this segment is a concrete, quantifiable initiative — not a generic "improve retention" recommendation.

---

## Finding 4: Repeat Purchase Behavior Is Structurally Rare — A Real Characteristic of the Business, Not a Data Gap

**The finding:** 97% of customers (90,557 of 93,358) made exactly one purchase in the full ~2-year window. Cohort retention analysis confirms this holds across nearly every monthly cohort: **month-1 retention is under 1% for every statistically meaningful cohort** (the two cohorts showing artificially high retention, 2016-09 and 2016-12, have only 1-2 customers each and are not meaningful).

**Why this matters methodologically:** this ruled out a standard quintile-based RFM segmentation (which requires spread across the Frequency dimension) and required an adapted approach using Recency × Monetary value plus a separate "Loyal/Repeat" flag. This is a real data-driven adjustment, not a shortcut.

**Stakeholder:** Retention / CRM lead; Product/Growth.

**Recommendation:** Retention is not currently a strength of this marketplace and is unlikely to improve without deliberate intervention (loyalty program, post-purchase engagement, subscription mechanics). Given Finding 3, the business case is strongest for winning back *lapsed high-value* one-time buyers rather than trying to convert the broad low-value base into repeat customers.

---

## Limitations & What This Data Cannot Answer

Being explicit about this is part of doing the analysis honestly:

- **No cost or margin data.** All revenue figures are top-line price/freight values; we cannot say which categories or customers are actually *profitable*, only which generate the most revenue.
- **No carrier/operational detail.** We can identify *which* sellers and *which* corridor (SP→RJ) underperform, but not *why* (carrier choice, warehouse location, packaging, staffing) — that requires operational data we don't have.
- **No marketing/CRM history.** We cannot attribute the near-zero repeat-purchase rate to any single cause (pricing, competition, lack of loyalty programs, one-off gift purchases) without customer contact and campaign data.
- **Correlation vs. causation on delivery delay:** the review-score relationship is very strong and statistically robust, but we have not ruled out confounders — e.g., whether certain product categories are both inherently slower to ship *and* inherently harder to satisfy regardless of speed. The category-level cross-validation (Finding 1) makes a pure confound unlikely to explain the whole effect, but it hasn't been formally isolated (e.g., via regression controlling for category).
- **Geographic data is at zip-prefix resolution**, not exact address — sufficient for state/regional analysis, not for route-level logistics optimization.

---

## Summary of Recommendations (Ranked by Estimated Leverage)

1. **Audit the SP→RJ shipping corridor** — concentrated, specific, fixable.
2. **Screen and audit sellers with >20% late-delivery rate (≥30 orders)** — concrete rule, cuts across regions.
3. **Launch a win-back campaign targeting the Lapsed High-Value segment** (11,304 customers, $4.1M historical value).
4. **Treat on-time delivery as the top lever for review scores and satisfaction** — ahead of product or pricing changes.
5. *(Lower confidence, needs more data)* Investigate retention mechanics — loyalty program or post-purchase engagement — given near-zero organic repeat purchase.