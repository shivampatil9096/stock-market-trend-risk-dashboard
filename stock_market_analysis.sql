/* ============================================================
   STOCK MARKET TREND & RISK ANALYSIS DASHBOARD
   SQL Script — Schema + Analysis Queries
   Matches: Companies.csv, Stock_Prices.csv, Transactions.csv
            (also loaded into Stock_Market_Analysis.xlsx)
   ============================================================ */

-- ============================================================
-- 1. SCHEMA
-- ============================================================

CREATE TABLE companies (
    company_id     INT PRIMARY KEY,
    ticker         VARCHAR(10),
    company_name   VARCHAR(100),
    sector         VARCHAR(50),
    asset_class    VARCHAR(30)      -- Equity, ETF, Bond, Commodity, Currency
);

CREATE TABLE stock_prices (
    price_id       BIGINT PRIMARY KEY,
    company_id     INT REFERENCES companies(company_id),
    trade_date     DATE,
    open_price     DECIMAL(10,2),
    high_price     DECIMAL(10,2),
    low_price      DECIMAL(10,2),
    close_price    DECIMAL(10,2),
    volume         BIGINT
);

CREATE TABLE transactions (
    transaction_id BIGINT PRIMARY KEY,
    company_id     INT REFERENCES companies(company_id),
    trade_date     DATE,
    transaction_type VARCHAR(10),   -- BUY / SELL
    quantity       INT,
    price          DECIMAL(10,2),
    asset_class    VARCHAR(30)
);

-- Load data (adjust for your DBMS — example shown for PostgreSQL)
-- \copy companies FROM 'companies.csv' WITH CSV HEADER;
-- \copy stock_prices FROM 'stock_prices.csv' WITH CSV HEADER;
-- \copy transactions FROM 'transactions.csv' WITH CSV HEADER;


-- ============================================================
-- 2. BULLET 1 — "Analyzed 10+ years of historical price data
--    across 500 S&P companies using SQL"
-- ============================================================

-- 2a. Data validation / row & date-range check
SELECT
    COUNT(*)                    AS total_rows,
    MIN(trade_date)             AS earliest_date,
    MAX(trade_date)             AS latest_date,
    COUNT(DISTINCT company_id)  AS total_companies
FROM stock_prices;

-- 2b. Daily returns per company
SELECT
    company_id,
    trade_date,
    close_price,
    LAG(close_price) OVER (PARTITION BY company_id ORDER BY trade_date) AS prev_close,
    ROUND(
        (close_price - LAG(close_price) OVER (PARTITION BY company_id ORDER BY trade_date))
        / LAG(close_price) OVER (PARTITION BY company_id ORDER BY trade_date) * 100, 2
    ) AS daily_return_pct
FROM stock_prices;

-- 2c. 50-day moving average (trend signal)
SELECT
    company_id,
    trade_date,
    close_price,
    AVG(close_price) OVER (
        PARTITION BY company_id
        ORDER BY trade_date
        ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
    ) AS moving_avg_50d
FROM stock_prices;

-- 2d. Yearly growth ranking across all companies
SELECT
    c.ticker,
    c.company_name,
    EXTRACT(YEAR FROM sp.trade_date) AS trade_year,
    ROUND(
        (MAX(sp.close_price) - MIN(sp.close_price)) / MIN(sp.close_price) * 100, 2
    ) AS yearly_growth_pct
FROM stock_prices sp
JOIN companies c ON c.company_id = sp.company_id
GROUP BY c.ticker, c.company_name, EXTRACT(YEAR FROM sp.trade_date)
ORDER BY yearly_growth_pct DESC;

-- 2e. Volatility / risk per company (std dev of daily returns)
WITH daily_returns AS (
    SELECT
        company_id,
        trade_date,
        (close_price - LAG(close_price) OVER (PARTITION BY company_id ORDER BY trade_date))
            / LAG(close_price) OVER (PARTITION BY company_id ORDER BY trade_date) AS daily_return
    FROM stock_prices
)
SELECT
    c.ticker,
    c.asset_class,
    ROUND(STDDEV(dr.daily_return) * 100, 3) AS volatility_pct
FROM daily_returns dr
JOIN companies c ON c.company_id = dr.company_id
WHERE dr.daily_return IS NOT NULL
GROUP BY c.ticker, c.asset_class
ORDER BY volatility_pct DESC;


-- ============================================================
-- 3. BULLET 2 — "Power BI dashboard, 1M+ transaction records,
--    5 asset classes" — these queries feed Power BI directly
-- ============================================================

-- 3a. Daily transaction volume & value by asset class (main trend chart)
SELECT
    trade_date,
    asset_class,
    COUNT(transaction_id)      AS total_transactions,
    SUM(quantity * price)      AS total_transaction_value
FROM transactions
GROUP BY trade_date, asset_class
ORDER BY trade_date;

-- 3b. Buy vs Sell breakdown (slicer/filter source)
SELECT
    asset_class,
    transaction_type,
    COUNT(*)        AS num_transactions,
    SUM(quantity)   AS total_quantity
FROM transactions
GROUP BY asset_class, transaction_type;

-- 3c. Top 10 most actively traded companies (leaderboard visual)
SELECT
    c.ticker,
    c.asset_class,
    COUNT(t.transaction_id) AS num_transactions,
    SUM(t.quantity)         AS total_volume
FROM transactions t
JOIN companies c ON c.company_id = t.company_id
GROUP BY c.ticker, c.asset_class
ORDER BY total_volume DESC
LIMIT 10;

-- 3d. Flat, denormalized export table — THIS is what gets imported into Power BI
--     (mirrors the "PowerBI_Import_Data" sheet in the Excel workbook)
SELECT
    sp.trade_date,
    c.ticker,
    c.asset_class,
    c.sector,
    sp.close_price,
    sp.volume AS daily_volume,
    COALESCE(tx.num_transactions, 0)        AS num_transactions,
    COALESCE(tx.total_transaction_value, 0) AS total_transaction_value
FROM stock_prices sp
JOIN companies c ON c.company_id = sp.company_id
LEFT JOIN (
    SELECT trade_date, company_id,
           COUNT(*) AS num_transactions,
           SUM(quantity * price) AS total_transaction_value
    FROM transactions
    GROUP BY trade_date, company_id
) tx ON tx.trade_date = sp.trade_date AND tx.company_id = sp.company_id
ORDER BY sp.trade_date, c.ticker;


-- ============================================================
-- 4. BULLET 3 — "Regression/correlation on 15 years of data,
--    forecast quarterly returns, Excel"
--    SQL prepares the clean quarterly data; the regression and
--    correlation formulas themselves live in Excel (SLOPE,
--    INTERCEPT, RSQ, CORREL — see Regression_Forecast_Analysis
--    and Sector_Correlation_Matrix sheets in the workbook).
-- ============================================================

-- 4a. Quarterly returns per company — exported to Excel for regression
SELECT
    c.ticker,
    EXTRACT(YEAR FROM sp.trade_date)    AS trade_year,
    EXTRACT(QUARTER FROM sp.trade_date) AS trade_quarter,
    ROUND(
        (MAX(sp.close_price) - MIN(sp.close_price)) / MIN(sp.close_price) * 100, 2
    ) AS quarterly_return_pct
FROM stock_prices sp
JOIN companies c ON c.company_id = sp.company_id
GROUP BY c.ticker, EXTRACT(YEAR FROM sp.trade_date), EXTRACT(QUARTER FROM sp.trade_date)
ORDER BY c.ticker, trade_year, trade_quarter;

-- 4b. Asset-class average quarterly returns — exported for correlation matrix in Excel
SELECT
    c.asset_class,
    EXTRACT(YEAR FROM sp.trade_date)    AS trade_year,
    EXTRACT(QUARTER FROM sp.trade_date) AS trade_quarter,
    ROUND(AVG(sp.close_price), 2) AS avg_close_price
FROM stock_prices sp
JOIN companies c ON c.company_id = sp.company_id
GROUP BY c.asset_class, EXTRACT(YEAR FROM sp.trade_date), EXTRACT(QUARTER FROM sp.trade_date)
ORDER BY c.asset_class, trade_year, trade_quarter;

/* ============================================================
   END OF SCRIPT
   Next steps:
     1. Run schema + load CSVs into your DBMS
     2. Run section 3d query -> export/connect result to Power BI
     3. Run section 4a/4b queries -> paste into Excel, apply
        SLOPE / INTERCEPT / RSQ / CORREL (see workbook)
   ============================================================ */
