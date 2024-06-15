#' nc to rasterlayer
#'
#'
#' converts a .nc pollution file to a raster layer

nc_to_raster_layer <- function(nc_file_path, pm2.5_var_name, lat_var_name, long_var_name){

  # Open the NetCDF file
  nc_file <- nc_open(nc_file_path)

  # Extract the PM2.5 variable
  pm25_data <- ncvar_get(nc_file, pm2.5_var_name)

  # Extract the latitude and longitude
  lat <- ncvar_get(nc_file, lat_var_name)
  lon <- ncvar_get(nc_file, long_var_name)

  # Close the NetCDF file
  nc_close(nc_file)

  # Reverse the latitude data and the corresponding PM2.5 data
  lat <- rev(lat)
  pm25_data <- pm25_data[, ncol(pm25_data):1]

  # Convert the PM2.5 data into a raster layer
  r <- raster(ncol = length(lon), nrow = length(lat), xmn = min(lon), xmx = max(lon), ymn = min(lat), ymx = max(lat))

  # Fill the raster with PM2.5 data
  values(r) <- as.vector(pm25_data)

  # Set CRS (Coordinate Reference System)
  crs(r) <- CRS("+proj=longlat +datum=WGS84 +no_defs")

  return(r)
}


#' Processes a yearly pollution raster
#'
#' @param unit_raster The raster representing the weather variable for a specific unit.
#' @param admin_level_shp_file Shapefile representing the administrative boundaries.
#' @param admin_level_shp_raster Rasterized version of the administrative boundaries.
#' @param var_type Type of weather variable ("tmp.2m" for temperature, "tot.precip" for total precipitation).
#'
#' @return A tibble containing processed weather data collapsed to the administrative level.
#'
#' @export
#'

process_weather_raster <- function(unit_raster_pol, unit_raster_pop, admin_level_shp_file, admin_level_shp_raster, var_type = "tmp.2m"){ # other option for var_type: tot.precip

  #### creating a pipeline for a single years-----------------------

  #> unit raster crs
  unit_raster_crs <- st_crs(unit_raster)

  #> raster name
  unit_raster_name_raw <- names(unit_raster)

  #> raster day, month, year, hr extract
  unit_raster_date_hr <- lubridate::as_datetime(str_remove(unit_raster_name_raw, "^[A-Za-z]"))

  # day
  cur_day <- day(unit_raster_date_hr)

  # month
  cur_month <- month(unit_raster_date_hr)

  # year
  cur_year <- year(unit_raster_date_hr)

  # hour
  cur_hour <- hour(unit_raster_date_hr)


  # crop the unit_raster using admin level shapefile
  unit_raster_cropped_admin_lev_shp_file <- raster::crop(unit_raster, admin_level_shp_file)


  # mask the unit_raster_cropped using admin level shapefile
  unit_raster_cropped_admin_lev_shp_file <- raster::mask(unit_raster_cropped_admin_lev_shp_file,
                                                         admin_level_shp_raster)



  # print("cur crop raster cropped and masked to admin level shp file")


  # create a raster brick containing the admin level shp and unit rasters (both now have the same res)
  unit_rast_admin_lev_shp_raster_brick <-  admin_level_shp_raster %>%
    raster::addLayer(unit_raster_cropped_admin_lev_shp_file)


  # convert raster brick to dataframe and filter out NAs in rasters
  unit_rast_admin_lev_shp_raster_brick_df <- raster::rasterToPoints(unit_rast_admin_lev_shp_raster_brick) %>%
    as_tibble() %>%
    dplyr::filter(!is.na(!!as.symbol(unit_raster_name_raw)), !is.na(!!as.symbol("uid_for_rasterization")))

  # print("raster brick created")

  # # convert to a light raster brick using the arrow package
  # unit_rast_admin_lev_shp_raster_brick_df_light <- arrow::as_arrow_table(unit_rast_admin_lev_shp_raster_brick_df)


  if(var_type == "tmp.2m"){

    # collapse to admin level polygon
    unit_rast_admin_lev_shp_raster_brick_df_light_collapse <- unit_rast_admin_lev_shp_raster_brick_df %>%
      dplyr::group_by(!!as.symbol("uid_for_rasterization")) %>%
      dplyr::summarise(avg_tmp2m_kelvin = mean(!!as.symbol(unit_raster_name_raw), na.rm = TRUE),
                       min_tmp2m_kelvin = min(!!as.symbol(unit_raster_name_raw), na.rm = TRUE),
                       max_tmp2m_kelvin = max(!!as.symbol(unit_raster_name_raw), na.rm = TRUE)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(cur_day = cur_day,
                    cur_month = cur_month,
                    cur_year = cur_year,
                    cur_hour = cur_hour) %>%
      dplyr::select(uid_for_rasterization, cur_day, cur_month, cur_year, cur_hour, avg_tmp2m_kelvin,
                    min_tmp2m_kelvin, max_tmp2m_kelvin)

    # print("collapsed dataset generated")
    return(unit_rast_admin_lev_shp_raster_brick_df_light_collapse)
    print("done!")


  } else if (var_type == "tot.precip"){

    # collapse to admin level polygon
    unit_rast_admin_lev_shp_raster_brick_df_light_collapse <- unit_rast_admin_lev_shp_raster_brick_df %>%
      dplyr::group_by(!!as.symbol("uid_for_rasterization")) %>%
      dplyr::collect() %>%
      dplyr::summarise(avg_precip_metre = mean(!!as.symbol(unit_raster_name_raw), na.rm = TRUE),
                       min_precip_metre = min(!!as.symbol(unit_raster_name_raw), na.rm = TRUE),
                       max_precip_metre = max(!!as.symbol(unit_raster_name_raw), na.rm = TRUE),
                       tot_precip_metre = sum(!!as.symbol(unit_raster_name_raw), na.rm = TRUE)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(cur_day = cur_day,
                    cur_month = cur_month,
                    cur_year = cur_year,
                    cur_hour = cur_hour) %>%
      dplyr::select(uid_for_rasterization, cur_day, cur_month, cur_year, cur_hour, avg_precip_metre,
                    min_precip_metre, max_precip_metre, tot_precip_metre)
    # print("collapsed dataset generated")
    return(unit_rast_admin_lev_shp_raster_brick_df_light_collapse)
    print("done!")

  }

}

#' Function to chunk the list into groups of n, with the last sublist containing the remaining elements
#'
#'
#'
#'

chunk_list <- function(lst, n) {
  # Calculate the number of full chunks
  full_chunks <- length(lst) %/% n
  # Calculate the total number of chunks
  total_chunks <- full_chunks + ifelse(length(lst) %% n > 0, 1, 0)
  # Create indices for splitting
  indices <- rep(1:total_chunks, each = n)[1:length(lst)]
  # Split the list according to the indices
  split(lst, indices)
}


#' Standardizes a data frame by taking care of all menial things (see description): v2
#'
#'
#' Automatically coerces columns to right types, makes sure that all missing values in
#' character columns show up like "" and all missing values in numeric columns show up
#' like NA. But, it keeps the shrug uid columns in character form so as to not mess up
#' uid's that have a atleast one leading zeros.
#'
#' @import dplyr
#' @import stringr
#'
#' @param df R dataframe/tibble to be standardized.
#' @param
#'
#' @return returns a standardized dataframe. Please inspect once to make sure you get what is expected
#'         and continue further standardization, if needed.
#'
#' @examples
#'
#' # standardize_df(df)
#'
#' @export
#'

standardize_df_v2 <- function(df, matches_regex){

  df_standardized <-  df %>%
    mutate_all(~ if_else(is.na(.), "NA", as.character(.))) %>%
    mutate(across(-c(matches(matches_regex)), ~{
      if (all(!is.na(.) & (is.numeric(.) | str_detect(as.character(.), "^-?\\d+\\.?\\d*$") | . == "NA" |
                           str_detect(as.character(.),  "\\d+[eE][+-]?\\d+")))) {
        readr::parse_number(as.character(.))
      } else {
        .
      }
    })) %>%
    mutate_all(~ if_else(. == "NA", NA, .)) %>%
    mutate(across(where(is.character), ~ if_else(is.na(.), "", as.character(.))))

  return(df_standardized)
}
