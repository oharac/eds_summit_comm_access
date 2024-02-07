
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
census_states <- c('MS')
proj <- 'EPSG:5070'

# polygons for US states
states <- tigris::states(cb = TRUE) |> 
    st_transform(proj) |>
    rmapshaper::ms_simplify(keep = 0.2) |> 
    filter(NAME %in% census_states)
str(states)

# census variable to pull in
var_name <- "B01003_001"

# fetch census data
df <- get_acs(
    geography = 'tract',
    variable = var_name,
    state = census_states,
    year = 2022,
    geometry = TRUE) |>
    st_transform(proj)

str(df)


# risk data
dat <-read.csv("NRI_Table_CensusTracts_Mississippi/NRI_Table_CensusTracts_Mississippi.csv") |>
    transform(geoid = as.character(TRACTFIPS))

names(dat)[names(dat) == 'STCOFIPS'] <- 'fips'

#$ combine risk and census data
risk_census <- df |>
    left_join(dat)
risk_census


## make a map 
library(scico) # color scales

risk_census |>
    ggplot() +
    geom_sf(aes(fill = RISK_SCORE), 
            color = NA) +
    theme_void() +
    theme(legend.position = 'bottom') +
    guides(fill = guide_colorbar(
        title = "Risk",
        title.position = "top",
        title.theme = element_text(face = 'bold'),
        direction = "horizontal", 
        position = "bottom", 
        barwidth = 20, 
        barheight = 1
    )) +
    scale_fill_scico(palette ='acton',
                     direction = -1,
                     labels = scales::label_comma()) 
