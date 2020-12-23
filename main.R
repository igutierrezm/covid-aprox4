library(magrittr)
source("R/utils.R")
rstan::rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Carga las dos BBDD relevantes: la de vecinos y la de contagios
vecinos   <- readRDS("data/vecinos.rds")
contagios <- readRDS("data/contagios.rds")

# Prepara la BBDD para su uso en stan
data <- prepare_stan_data(
    Nlags = 1,
    edges = vecinos,
    data = contagios, 
    y = "value", 
    t = "fecha", 
    i = "codigo_comuna", 
    x = c("cuarentena", "cons")
)

# Compile y ajusta el modelo de Leo
model  <- "aproximacion4"
object <- rstan::stan_model(paste0("stan/", model, ".stan"))
fit    <- rstan::sampling(object = object, data = data, iter = 100)

# Save the results
fit@stanmodel@dso <- new("cxxdso")
saveRDS(fit, file = "data/fit.rds")