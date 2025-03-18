###############################################################
# Time Series Analysis: Acme United Corporation Stock (ACU)
# Author: MITESH KUMAR (M23MAC004)
# Date: March 2025
# Description: Analysis and forecasting of ACU stock prices
###############################################################

# Load required libraries
library(quantmod)
library(forecast)
library(ggplot2)
library(tseries)

# Create plots directory if it doesn't exist
if (!dir.exists("plots")) {
  dir.create("plots")
}

# Source helper functions
source("analysis_functions.R")

# Part 1: Data Acquisition and Preparation
# ----------------------------------------

# Fetch ACU data from Yahoo Finance (from 2020-10-21 to 2024-10-20)
message("Fetching ACU stock data from Yahoo Finance...")
y <- getSymbols("ACU", src = "yahoo", from = as.Date("2020-10-21"), to = as.Date("2024-10-20"), auto.assign = FALSE)

# Convert to time series object using the closing price
y_ts <- ts(y[, "ACU.Close"], start = c(2020, 10), frequency = 365)

# Save raw data
saveRDS(y_ts, file = "data/acu_ts_data.rds")

# Basic statistics
summary_stats <- data.frame(
  Min = min(y_ts, na.rm = TRUE),
  Max = max(y_ts, na.rm = TRUE),
  Mean = mean(y_ts, na.rm = TRUE),
  Median = median(y_ts, na.rm = TRUE),
  SD = sd(y_ts, na.rm = TRUE)
)
write.csv(summary_stats, "data/summary_statistics.csv", row.names = FALSE)

# Part 2: Data Visualization
# --------------------------

# 1. Plot time series data
plot_ts <- autoplot(y_ts) +
  ggtitle("Time Series Plot of ACU Closing Prices (Last 4 Years)") +
  xlab("Time") +
  ylab("Closing Price (USD)") +
  theme_minimal()

print(plot_ts)
ggsave("plots/acu_time_series.png", plot_ts, width = 10, height = 6)

# Part 3: Train-Test Split
# ------------------------

# 2. Create appropriate train and test sets (80-20 split)
message("Splitting data into training and test sets (80-20)...")
train_size <- floor(0.8 * length(y_ts))
train_set <- window(y_ts, end = c(time(y_ts)[train_size]))
test_set <- window(y_ts, start = c(time(y_ts)[train_size + 1]))

# Plot train-test split
plot_split <- autoplot(y_ts) +
  autolayer(train_set, series = "Training", color = "blue") +
  autolayer(test_set, series = "Testing", color = "red") +
  ggtitle("Training and Test Split for ACU Stock Data") +
  xlab("Time") +
  ylab("Closing Price (USD)") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(plot_split)
ggsave("plots/train_test_split.png", plot_split, width = 10, height = 6)

# Part 4: ARIMA Modeling
# ----------------------

# 3. Identify an appropriate ARIMA model based on the train set
message("Fitting ARIMA model...")
auto_arima_model <- auto.arima(train_set, seasonal = TRUE)
arima_summary <- capture.output(summary(auto_arima_model))
writeLines(arima_summary, "results/arima_model_summary.txt")

# 4. Residual diagnostic checking of the ARIMA model
png("plots/arima_residuals.png", width = 800, height = 600)
checkresiduals(auto_arima_model)
dev.off()

# 5. Use ARIMA model to forecast for the length of the test set
arima_forecast <- forecast(auto_arima_model, h = length(test_set))

# Plot ARIMA forecast
plot_arima_forecast <- autoplot(arima_forecast) +
  autolayer(test_set, series = "Actual", color = "red") +
  ggtitle("ARIMA Forecast for ACU Closing Prices") +
  xlab("Time") +
  ylab("Forecasted Closing Price (USD)") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(plot_arima_forecast)
ggsave("plots/arima_forecast.png", plot_arima_forecast, width = 10, height = 6)

# Part 5: ETS Modeling
# --------------------

# 6. Identify an appropriate ETS model based on the same train set
message("Fitting ETS model...")
ets_model <- stlf(train_set, method = "ets")
ets_summary <- capture.output(summary(ets_model$model))
writeLines(ets_summary, "results/ets_model_summary.txt")

# 7. Residual diagnostic checking of the ETS model
png("plots/ets_residuals.png", width = 800, height = 600)
checkresiduals(ets_model)
dev.off()

# 8. Use ETS model to forecast for the length of the test set
ets_forecast <- forecast(ets_model, h = length(test_set))

# Plot ETS forecast
plot_ets_forecast <- autoplot(ets_forecast) +
  autolayer(test_set, series = "Actual", color = "red") +
  ggtitle("ETS Forecast for ACU Closing Prices") +
  xlab("Time") +
  ylab("Forecasted Closing Price (USD)") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(plot_ets_forecast)
ggsave("plots/ets_forecast.png", plot_ets_forecast, width = 10, height = 6)

# Part 6: Model Comparison
# ------------------------

# 9. Compare the two models
# Calculate accuracy metrics for both forecasts
arima_accuracy <- accuracy(arima_forecast, test_set)
ets_accuracy <- accuracy(ets_forecast, test_set)

# Store accuracy results
accuracy_results <- rbind(
  data.frame(Model = "ARIMA", t(arima_accuracy[2, ])),
  data.frame(Model = "ETS", t(ets_accuracy[2, ]))
)
write.csv(accuracy_results, "results/accuracy_comparison.csv", row.names = FALSE)

# 10. Cross-validation
message("Performing cross-validation...")

# Cross-validation function for ARIMA model
arima_cv <- function(train_set, h) {
  forecast(auto.arima(train_set), h = h)
}

# Cross-validation function for ETS model
ets_cv <- function(train_set, h) {
  forecast(ets(train_set), h = h)
}

# Perform cross-validation for ARIMA model
arima_cv_errors <- tsCV(train_set, arima_cv, h = 1)

# Perform cross-validation for ETS model
ets_cv_errors <- tsCV(train_set, ets_cv, h = 1)

# Calculate cross-validation MSE for both models
arima_cv_mse <- mean(arima_cv_errors^2, na.rm = TRUE)
ets_cv_mse <- mean(ets_cv_errors^2, na.rm = TRUE)

# Store cross-validation results
cv_results <- data.frame(
  Model = c("ARIMA", "ETS"),
  MSE = c(arima_cv_mse, ets_cv_mse)
)
write.csv(cv_results, "results/cross_validation_results.csv", row.names = FALSE)

# Compare model performance
message("\n=== Model Accuracy Comparison ===")
print("ARIMA Model Accuracy:")
print(arima_accuracy)

message("\n")
print("ETS Model Accuracy:")
print(ets_accuracy)

message("\n=== Cross-Validation Results ===")
cat("ARIMA Cross-Validation MSE:", arima_cv_mse, "\n")
cat("ETS Cross-Validation MSE:", ets_cv_mse, "\n")

# Determine which model performed better
if (arima_cv_mse < ets_cv_mse) {
  cat("\nBased on cross-validation, ARIMA performs better.\n")
} else {
  cat("\nBased on cross-validation, ETS performs better.\n")
}

# Part 7: Combined Visualization
# ------------------------------

# Create combined plot for forecasting comparison
plot_comparison <- autoplot(y_ts) +
  autolayer(arima_forecast, series = "ARIMA", PI = FALSE, color = "blue") +
  autolayer(ets_forecast, series = "ETS", PI = FALSE, color = "red") +
  autolayer(test_set, series = "Actual", color = "black") +
  ggtitle("Comparison of ARIMA and ETS Forecasts for ACU Stock") +
  xlab("Time") +
  ylab("Closing Price (USD)") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(plot_comparison)
ggsave("plots/forecast_comparison.png", plot_comparison, width = 10, height = 6)

message("Analysis complete. Results are stored in 'results' and 'plots' directories.")
