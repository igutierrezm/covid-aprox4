#' Prepare the data for stan
#'
#' @param Nlags the number of lags in the offset.
#' @param edges a dataframe with the edges.
#' @param data a data frame with the reponses..
#' @param y the name of the response variable.
#' @param t the time id (variable name).
#' @param i the area id (variable name).
#' @param x the predictors (variable names).
#' @return A list ready for its use in model.stan
prepare_stan_data <- function(Nlags, edges, data, y, t, i, x) {
    # Sort the sample by area and period and add the offset
    data <- 
        data %>%
        dplyr::arrange(!!as.name(i), !!as.name(t))

    # Convert key variables to factors
    i_fct <- factor(data[[i]])
    t_fct <- factor(data[[t]])
    edge1_fct <- factor(edges[[1]], levels = levels(i_fct))
    edge2_fct <- factor(edges[[2]], levels = levels(i_fct))

    # Get encoded areas and periods
    i <- unique(as.numeric(i_fct))
    t <- unique(as.numeric(t_fct))

    # Compute the key model dimensions
    Nedges <- nrow(edges)
    Nareas <- length(i)
    Ntimes <- length(t)
    Npreds <- length(x)
    standata <- list(
        Nlags  = Nlags,
        Nedges = Nedges,
        Nareas = Nareas,
        Ntimes = Ntimes,
        Npreds = Npreds,
        i      = i,
        t      = t,
        y      = array(data[[y]], c(Ntimes, Nareas)),
        X      = array(data.matrix(data[x]), c(Ntimes, Nareas, Npreds)),
        edge1  = as.numeric(edge1_fct),
        edge2  = as.numeric(edge2_fct)
    )
    return(standata)
}
