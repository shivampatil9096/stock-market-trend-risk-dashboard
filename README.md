# Stock Market Trend & Risk Analysis Dashboard
![banner](github_banner_hd.png)

SQL · Power BI · Excel

Analyzed historical stock price and transaction data across 15 companies
spanning 5 asset classes (Equity, ETF, Bond, Commodity, Currency), building
an interactive dashboard and a regression-based forecasting model.

## Live Dashboard
[View the interactive Power BI dashboard here](https://app.powerbi.com/groups/me/reports/494fe462-6490-4169-9d73-651ac8399241/99fb18e2910abe6144e0?experience=power-bi)

## Dashboard Preview
![Dashboard Overview](overall.png)


## What's in this repo
| Folder | Contents |
|---|---|
| `sql/` | Schema + all analysis queries (daily returns, moving averages, volatility, quarterly aggregation) |
| `excel/` | Full workbook with live regression (SLOPE/INTERCEPT/RSQ) and correlation (CORREL) formulas |
| `data/` | Raw and cleaned CSV data used across SQL, Excel, and Power BI |
| `powerbi/` | Dashboard screenshots and the build guide used to construct it |

## 🗄️ SQL Queries & Results

### 1. Data Validation

![Query 1 result](query1_data_validation.png)

### 2. Daily Returns per Company

![Query 2 result](query2_daily_returns.png)

### 3. 50-Day Moving Average (Trend Signal)

![Query 3 result](query3_moving_average_50d.png)

### 4. Yearly Growth Ranking Across All Companies

![Query 4 result](query4_yearly_growth_ranking.png)

### 5. Volatility / Risk per Company (Std Dev of Daily Returns)

![Query 5 result](query5_volatility_risk.png)

### 6. Daily Transaction Volume & Value by Asset Class

![Query 6 result](query6_daily_transaction_volume.png)

### 7. Buy vs Sell Breakdown

![Query 7 result](query7_buy_sell_breakdown.png)

### 8. Top 10 Most Actively Traded Companies
![Query 8 result](query8_top10_traded_companies.png)

### 9. Quarterly Returns per Company (Exported for Excel Regression)

![Query 9 result](query9_quarterly_returns.png)

## Key Results
- 7,500+ daily price records across 15 companies analyzed via SQL window functions
- 14,900+ transaction records visualized in an interactive Power BI dashboard
- 86.7% directional forecast accuracy from a linear regression model built in Excel

## How it was built
1. **SQL** — cleaned and aggregated raw price/transaction data, computed daily
   returns, 50-day moving averages, and volatility using window functions.
2. **Excel** — built quarterly return tables, ran linear regression
   (SLOPE/INTERCEPT/RSQ) per company to forecast returns, and built a
   correlation matrix across asset classes.
3. **Power BI** — imported the SQL-aggregated table, built KPI cards, trend
   lines, bar/donut charts, a risk-vs-return scatter plot, and interactive
   slicers for real-time filtering.

## Explore the code
- [SQL queries](stock_market_analysis.sql)
- [Excel workbook](Stock_Market_Analysis.xlsx)
