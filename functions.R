moran <- function(
  x = NULL,
  distance.matrix = NULL,
  distance.threshold = NULL,
  verbose = TRUE
){

  #extracting weights from distance matrix
  x.distance.weights <- weights_from_distance_matrix(
    distance.matrix = distance.matrix,
    distance.threshold = distance.threshold
  )
  
  #length of the input vector
  x.length <- length(x)
  
  #computing expected Moran I
  moran.i.expected <- -1/(x.length - 1)
  
  #sum of weights
  x.distance.weights.sum <- sum(x.distance.weights)
  
  #centering x
  x.mean <- mean(x)
  x.centered <- x - x.mean
  
  #upper term of the Moran's I equation
  #sum of cross-products of the lags
  #x.centered %o% x.centered equals (xi - x.mean) * (xj - x.mean)
  cross.product.sum <- sum(x.distance.weights * x.centered %o% x.centered)
  
  #lower term of the Moran's I equation
  #variance of the centered x
  x.centered.variance <- sum(x.centered^2)
  
  #observed Moran's I
  moran.i.observed <- (x.length / x.distance.weights.sum) * (cross.product.sum/x.centered.variance)
  
  #preparing moran plot
  #computing weighted mean of the lag
  x.lag <- apply(
    X = x.distance.weights,
    MARGIN = 1,
    FUN = function(y){y %*% x}
  )
  
  #preparing title
  plot.title <- paste0(
    "Moran's I = ",
    round(moran.i.observed, 3)
  )
  
  #preparing data frame
  plot.df <- data.frame(
    x = spatialRF::rescale_vector(x),
    x.lag = spatialRF::rescale_vector(x.lag)
  )
  
  #moran plot
  #plot
  moran.plot <- ggplot2::ggplot(data = plot.df) +
    ggplot2::aes(
      x = x,
      y = x.lag
    ) +
    ggplot2::geom_point(alpha = 0.75, color = "#f1605d") +
    ggplot2::geom_smooth(
      method = "lm",
      color = "#0d0887",
      fill = "#0d0887",
      se = TRUE,
      alpha = 0.2,
      formula = y ~ x,
      size = 0.6,
      level = 0.99
    ) +
    ggplot2::xlab("Value") +
    ggplot2::ylab("Lagged value") +
    ggplot2::theme(
      legend.position = "none", 
      plot.margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 0)
      ) +
    ggplot2::ggtitle(plot.title) +
    ggplot2::theme_bw(base_size = 10) + 
    ggplot2::coord_fixed(xlim = c(0, 1), ylim = c(0, 1))
  
  moran.plot

}