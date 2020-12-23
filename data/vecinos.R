library(magrittr)
is_integer64 <- function(x) {class(x)[1] == "integer64"}
noctua::athena() %>%
    noctua::dbConnect(
        profile_name   = "covid-anid",
        s3_staging_dir = "s3://covid-anid/athena-results/",
        schema_name    = "struct_covid",
        region_name    = "us-east-1",
        bigint         = "integer"
    ) %>%
    dplyr::tbl("vecinos") %>%
    dplyr::collect() %>%
    dplyr::filter(codigo_comuna1 < codigo_comuna2) %>%
    dplyr::select(codigo_comuna1, codigo_comuna2) %>%
    dplyr::mutate(dplyr::across(where(is_integer64), as.integer)) %>%
    saveRDS("data/vecinos.rds")
