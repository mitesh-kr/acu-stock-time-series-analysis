###############################################################
# Helper Functions for Time Series Analysis
# Author: MITESH KUMAR (M23MAC004)
# Date: March 2025
###############################################################

# Function to calculate additional performance metrics
calculate_performance_metrics <- function(forecast_obj, test_data) {
  # Get point forecasts
  point_forecasts <- forecast_obj$mean

  # Calculate forecasting errors
  errors <- test_data - point_forecasts

  # Calculate additional metrics
  metrics <- list(
    # Basic metrics (already in accuracy function but included for completeness)
    ME = mean(errors, na.rm = TRUE),
    RMSE = sqrt(mean(errors^2, na.rm = TRUE)),
    MAE = mean(abs(errors), na.rm = TRUE),

    # Additional metrics
    MASE = mean(abs(errors)) / mean(abs(diff(test_data))),
    R_squared = 1 - sum(errors^2) / sum((test_data - mean(test_data))^2),

    # Direction accuracy - percentage of times forecast correctly predicts up/down movement
    DA = mean(sign(diff(c(NA, point_forecasts))) == sign(diff(c(NA, test_data))), na.rm = TRUE)
  )

  return(metrics)
}

# Function to plot ACF and PACF
plot_acf_pacf <- function(time_series, filename = NULL) {
  par(mfrow = c(2, 1))
  acf(time_series, main = "Autocorrelation Function (ACF)")
  pacf(time_series, main = "Partial Autocorrelation Function (PACF)")

  if (!is.null(filename)) {
    dev.copy(png, filename, width = 800, height = 600)
    dev.off()
    par(mfrow = c(1, 1))
  }
}

# Function to test stationarity
test_stationarity <- function(time_series) {
  # Augmented Dickey-Fuller test
  adf_test <- adf.test(time_series)

  # KPSS test
  kpss_test <- kpss.test(time_series)

  # Return results
  results <- list(
    adf = list(
      statistic = adf_test$statistic,
      p_value = adf_test$p.value,
      is_stationary = adf_test$p.value < 0.05
    ),
    kpss = list(
      statistic = kpss_test$statistic,
      p_value = kpss_test$p.value,
      is_stationary = kpss_test$p.value >= 0.05
    )
  )

  # Overall conclusion
  results$conclusion <- ifelse(
    results$adf$is_stationary && results$kpss$is_stationary,
    "Series is stationary",
    "Series may not be stationary"
  )

  return(results)
}

# Function to create seasonal decomposition plot
plot_decomposition <- function(time_series, frequency = NULL, filename = NULL) {
  # If frequency is not provided, use the frequency of the time series
  if (is.null(frequency)) {
    frequency <- frequency(time_series)
  }

  # Perform decomposition
  decomp <- stl(time_series, s.window = "periodic")

  # Plot decomposition
  plot_decomp <- autoplot(decomp) +
    ggtitle("Seasonal Decomposition of Time Series") +
    theme_minimal()

  if (!is.null(filename)) {
    ggsave(filename, plot_decomp, width = 10, height = 8)
  }

  return(decomp)
}

# Function to compare multiple forecast methods visually
compare_forecasts <- function(actual, forecasts_list, title = "Forecast Comparison", filename = NULL) {
  # Create base plot with actual values
  plot <- autoplot(actual, series = "Actual", color = "black", size = 1)

  # Add each forecast
  colors <- c("red", "blue", "green", "purple", "orange", "brown")

  for (i in 1:length(forecasts_list)) {
    forecast_name <- names(forecasts_list)[i]
    forecast_obj <- forecasts_list[[i]]
    color_idx <- (i - 1) %% length(colors) + 1

    plot <- plot +
      autolayer(forecast_obj, series = forecast_name, PI = FALSE,
                color = colors[color_idx])
  }

  # Add title and labels
  plot <- plot +
    ggtitle(title) +
    xlab("Time") +
    ylab("Value") +
    theme_minimal() +
    theme(legend.position = "bottom")

  # Save if filename provided
  if (!is.null(filename)) {
    ggsave(filename, plot, width = 10, height = 6)
  }

  return(plot)
}

# Function to evaluate multiple models using multiple metrics
evaluate_models <- function(models_list, test_data) {
  # Initialize results data frame
  metrics <- c("ME", "RMSE", "MAE", "MPE", "MAPE", "MASE", "ACF1", "Theil's U")
  results <- data.frame(matrix(NA, nrow = length(models_list), ncol = length(metrics)))
  colnames(results) <- metrics
  rownames(results) <- names(models_list)

  # Calculate metrics for each model
  for (i in 1:length(models_list)) {
    model_name <- names(models_list)[i]
    model_forecast <- models_list[[i]]

    # Get accuracy measures
    acc <- accuracy(model_forecast, test_data)[2, ]  # Test set row

    # Add to results
    results[model_name, names(acc)] <- acc
  }

  return(results)
}
