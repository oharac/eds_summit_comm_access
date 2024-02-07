
library(tidyverse)
library(tidycensus)
library(sf)

# to access census data you need a key from here: https://api.census.gov/data/key_signup.html
# uncomment the code and run to set that us
#Sys.setenv(CENSUS_API_KEY='CENSUS KEY')
#readRenviron("~/.Renviron")

# what census variables exist?
census_vars <- tidycensus::load_variables(year = 2022, dataset = "acs1")
census_vars

# states of interest to pull and map data
census_states <- c('Mississippi')
proj <- 'EPSG:5070'

# polygons for US states
states <- tigris::states(cb = TRUE) |> 
    st_transform(proj) |>
    rmapshaper::ms_simplify(keep = 0.2) |> 
    filter(NAME %in% census_states)

# census variable to pull in
var_name <- "B01003_001"

# fetch census data
df <- get_acs(
    geography = 'tract',
    variable = var_name,
    state = 'MS',
    year = 2022,
    geometry = TRUE) |>
    st_transform(proj)

df


## make a mpa of the census variable
df |>
    ggplot() +
    geom_sf(aes(fill = estimate)) +
    theme_void()
