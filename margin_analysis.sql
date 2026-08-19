CREATE TABLE margin_accounts (
    account_id VARCHAR(20),
    client_id VARCHAR(20),
    region VARCHAR(30),
    product VARCHAR(30),
    collateral_value DECIMAL(18,2),
    loan_amount DECIMAL(18,2),
    margin_requirement_pct DECIMAL(5,2),
    required_collateral DECIMAL(18,2),
    eligible_collateral DECIMAL(18,2),
    exposure DECIMAL(18,2),
    margin_deficit DECIMAL(18,2),
    margin_call_amount DECIMAL(18,2),
    call_date DATE,
    due_date DATE,
    status VARCHAR(20),
    days_to_due INT,
    risk_band VARCHAR(20)
);

SELECT COUNT(*) AS total_records
FROM margin_accounts;

SELECT *
FROM margin_accounts
LIMIT 10;

##1: Find accounts requiring margin calls
## Which accounts have insufficient collateral and therefore require a margin call?
SELECT
    account_id,
    client_id,
    region,
    product,
    margin_deficit,
    margin_call_amount,
    status
FROM margin_accounts
WHERE margin_deficit > 0
ORDER BY margin_deficit DESC

##Query 2: Exposure by region Where is the exposure concentrated?
SELECT
    region,
    COUNT(*) AS account_count,
    SUM(exposure) AS total_exposure,
    SUM(margin_deficit) AS total_margin_deficit
FROM margin_accounts
GROUP BY region
ORDER BY total_exposure DESC;

##Query 3: Outstanding calls Business question: Which margin calls still require follow-up?
SELECT
    account_id,
    client_id,
    region,
    margin_call_amount,
    call_date,
    due_date,
    status
FROM margin_accounts
WHERE status IN ('Open', 'Overdue', 'Disputed')
ORDER BY due_date;

## Query 4: Overdue calls Which calls require immediate escalation?
SELECT
    account_id,
    client_id,
    region,
    margin_call_amount,
    due_date,
    status
FROM margin_accounts
WHERE status = 'Overdue'
ORDER BY margin_call_amount DESC;

##Query 5: High-risk accounts Business question: Which accounts need priority monitoring?
SELECT
    account_id,
    client_id,
    region,
    product,
    margin_deficit,
    risk_band
FROM margin_accounts
WHERE risk_band IN ('High', 'Critical')
ORDER BY margin_deficit DESC;

##Query 6: Risk by product : Which product has the largest collateral shortfall?
SELECT
    product,
    COUNT(*) AS account_count,
    SUM(exposure) AS total_exposure,
    SUM(margin_deficit) AS total_margin_deficit
FROM margin_accounts
GROUP BY product
ORDER BY total_margin_deficit DESC;

##Query 7: Risk concentration : This gives you a region × risk-band view.
SELECT
    region,
    risk_band,
    COUNT(*) AS account_count,
    SUM(margin_deficit) AS total_deficit
FROM margin_accounts
GROUP BY region, risk_band
ORDER BY total_deficit DESC;

##Query 8: Data-quality check
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN product IS NULL THEN 1 ELSE 0 END) AS missing_product,
    SUM(CASE WHEN eligible_collateral IS NULL THEN 1 ELSE 0 END) AS missing_collateral
FROM margin_accounts;

