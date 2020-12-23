library(magrittr)
is_integer64 <- function(x) {class(x)[1] == "integer64"}
noctua::athena() %>%
    noctua::dbConnect(
        profile_name   = "covid-anid",
        s3_staging_dir = "s3://covid-anid/athena-results/",
        schema_name    = "struct_covid",
        region_name    = "us-east-1"
    ) %>%
    dplyr::tbl("vw_casos_nuevos_imputados_dc") %>%
    dplyr::collect() %>%
    dplyr::mutate(
        dplyr::across(where(is_integer64), as.integer),
        cons = 1
    ) %>%
    saveRDS("data/contagios.rds")
    