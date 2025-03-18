# Time Series Analysis: Acme United Corporation Stock

This repository contains a time series analysis of Acme United Corporation stock (ACU) for a 4-year period from October 21, 2020, to October 20, 2024. The analysis compares the performance of ARIMA and ETS forecasting models.

## [Google Colab Link acme-united-analysis-script](https://colab.research.google.com/drive/13X8sq0OkSEYV3rtssGYOxhpls2JU_aC-?usp=sharing)
## [Google Colab Link analysis-functions](https://colab.research.google.com/drive/1BXWtkF7HCvQFvDciBT9m6erOCQ6axcEx?usp=sharing)

## Overview

This project was completed as an assignment for the Time Series Analysis course at IIT Jodhpur. It focuses on analyzing and forecasting the closing prices of Acme United Corporation stock using both ARIMA and ETS models.

## Data

- **Source**: Yahoo Finance (accessed through the `quantmod` R package)
- **Time Period**: October 21, 2020 to October 20, 2024
- **Variable**: Closing stock price (ACU.Close)
- **Sample Size**: 1005 data points

## Methodology

1. **Data Preparation**:
   - Fetched ACU stock data using the `quantmod` package
   - Split the data into training (80%) and test (20%) sets

2. **Model Building**:
   - Applied `auto.arima()` to identify the optimal ARIMA model
   - Implemented ETS modeling using `stlf()` and `ets()`
   - Conducted residual diagnostic checks for both models

3. **Forecasting**:
   - Generated forecasts using both models for the test period
   - Compared accuracy metrics including RMSE, MAE, and MAPE
   - Performed cross-validation to assess model stability

4. **Evaluation**:
   - Compared model performance based on accuracy metrics
   - Used cross-validation MSE for final model selection

## Results

- **ARIMA Model**: ARIMA(1,1,2) was identified as the best model
- **ETS Model**: ETS(A,N,N) (additive error, no trend, no seasonality)
- **Model Performance**:
  - ARIMA showed better performance on point accuracy metrics (RMSE, MAE)
  - ETS performed slightly better in cross-validation

## Repository Structure

```
time-series-analysis-acme-united/
├── README.md                       # Project overview and instructions
├── acme_united_analysis.R          # Main analysis script
├── analysis_functions.R            # Helper functions for analysis
├── .gitignore                      # Git ignore file
├── M23MAC004_Report.pdf            # Original assignment report
├── LICENSE                         # MIT License file
├── data/                           # Data directory
│   ├── acu_ts_data.rds             # Saved time series data
│   └── summary_statistics.csv      # Basic statistics of the data
├── plots/                          # Directory for generated plots
│   ├── acu_time_series.png         # Time series plot
│   ├── train_test_split.png        # Train-test split visualization
│   ├── arima_residuals.png         # ARIMA residual diagnostics
│   ├── arima_forecast.png          # ARIMA forecast plot
│   ├── ets_residuals.png           # ETS residual diagnostics
│   ├── ets_forecast.png            # ETS forecast plot
│   └── forecast_comparison.png     # Comparison of forecasts
└── results/                        # Directory for analysis results
    ├── arima_model_summary.txt     # ARIMA model summary
    ├── ets_model_summary.txt       # ETS model summary
    ├── accuracy_comparison.csv     # Comparison of accuracy metrics
    └── cross_validation_results.csv# Cross-validation results
```

## Requirements

- R (>= 4.0.0)
- Required R packages:
  - quantmod
  - forecast
  - ggplot2
  - tseries

## Usage

```r
# Clone the repository
git clone https://github.com/yourusername/time-series-analysis-acme-united.git

# Navigate to the directory
cd time-series-analysis-acme-united

# Run the analysis
Rscript acme_united_analysis.R
```

## Author

MITESH KUMAR (M23MAC004)  
Indian Institute of Technology Jodhpur
