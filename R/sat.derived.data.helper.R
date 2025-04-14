#' Convert NetCDF PM2.5 Data to RasterLayer
#'
#' This function reads PM2.5 data from a NetCDF file and converts it into a `RasterLayer` object
#' with a geographic coordinate reference system.
#'
#' @param nc_file_path A character string specifying the path to the NetCDF file.
#' @param pm2.5_var_name A character string specifying the name of the PM2.5 variable in the NetCDF file.
#' @param lat_var_name A character string specifying the name of the latitude variable in the NetCDF file.
#' @param long_var_name A character string specifying the name of the longitude variable in the NetCDF file.
#'
#' @return A `RasterLayer` object representing the PM2.5 data, georeferenced using the latitude
#' and longitude values from the NetCDF file.
#'
#' @details
#' The function performs the following steps:
#' \itemize{
#'   \item Opens the NetCDF file using `ncdf4::nc_open`.
#'   \item Extracts the PM2.5, latitude, and longitude variables.
#'   \item Reverses the latitude axis to match the raster orientation.
#'   \item Creates a raster using the longitude and latitude bounds.
#'   \item Fills the raster with the PM2.5 values.
#'   \item Assigns a WGS84 geographic coordinate reference system.
#' }
#'
#' This function is useful for converting gridded air quality data from NetCDF format to raster
#' for spatial analysis.
#'
#' @importFrom ncdf4 nc_open ncvar_get nc_close
#' @importFrom raster raster values crs
#' @importFrom sp CRS
#'
#' @export


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


#' Process Uncaptured UIDs with Raster Resampling and Population-Weighted Pollution Calculation
#'
#' This function handles administrative units (UIDs) that were missed in the original
#' population-weighted pollution aggregation. It rasterizes shapefile regions for these UIDs,
#' resamples pollution and population rasters to a finer resolution, and computes
#' population-weighted average PM2.5 values.
#'
#' @param uids_not_captured A numeric vector of `uid_for_rasterization` values corresponding to
#' regions that were not included in the initial processing.
#' @param unit_pol_raster A `RasterLayer` containing unit-level PM2.5 (or other pollutant) values.
#' @param unit_pop_raster A `RasterLayer` with unit-level population values at a coarser resolution.
#' @param ref_shp_file_to_be_rasterized A `sf` object representing the reference shapefile with a
#' column named `uid_for_rasterization` used for filtering and rasterization.
#' @param resample_to_res A numeric value specifying the target resolution (in degrees) to which
#' rasters are resampled. Defaults to `0.001`.
#' @param res_resample_from A numeric value indicating the original resolution (in degrees) of the
#' population raster. Defaults to `0.00833333` (approx. 1km).
#'
#' @return A data frame summarizing the population-weighted pollution for each UID, with the following columns:
#' \describe{
#'   \item{sh_rast}{UID of the processed shapefile region.}
#'   \item{total_population}{Total resampled population in the region.}
#'   \item{avg_pm2.5_pollution}{Population-weighted average PM2.5 value.}
#' }
#'
#' @details
#' For each UID, the function performs:
#' \itemize{
#'   \item Filtering the shapefile to the UID.
#'   \item Rasterizing the filtered polygon.
#'   \item Cropping, resampling, and masking the pollution and population rasters to match the polygon.
#'   \item Adjusting population raster values to represent densities before resampling.
#'   \item Creating a raster stack and converting to a data frame.
#'   \item Computing population weights and weighted pollution.
#'   \item Aggregating to produce population-weighted pollution summaries.
#' }
#'
#' This is useful for recovering and summarizing air quality data for regions initially excluded
#' due to raster alignment or small size.
#'
#' @importFrom dplyr filter mutate summarise group_by ungroup
#' @importFrom purrr map_dfr
#' @importFrom raster crop mask resample extent crs stack as.data.frame values
#' @importFrom fasterize fasterize
#' @importFrom arrow as_arrow_table
#'
#' @export

process_uncaptured_uids <- function(uids_not_captured, unit_pol_raster, unit_pop_raster, ref_shp_file_to_be_rasterized, resample_to_res = 0.001, res_resample_from = 0.00833333) {

  map_dfr(uids_not_captured, function(uid) {
    cat(sprintf("Processing UID: %d\n", uid))
    sh_admin_int_shp_unprocessed <- ref_shp_file_to_be_rasterized %>%
      filter(uid_for_rasterization == uid)

    sh_admin_int_shp_unprocessed_rasterized <- fasterize(sh_admin_int_shp_unprocessed, raster(ext = extent(sh_admin_int_shp_unprocessed), resolution = resample_to_res, crs = crs(sh_admin_int_shp_unprocessed)), field = "uid_for_rasterization", fun = "last")

    unit_pol_raster_crp_resamp_msk <- crop(unit_pol_raster, sh_admin_int_shp_unprocessed_rasterized) %>%
      resample(sh_admin_int_shp_unprocessed_rasterized, method = "ngb") %>%
      mask(sh_admin_int_shp_unprocessed_rasterized)

    unit_pop_raster_crp <- crop(unit_pop_raster, sh_admin_int_shp_unprocessed_rasterized)

    # replace population values with population densities before resampling
    raster::values(unit_pop_raster_crp) <- as.vector(unit_pop_raster_crp * (((resample_to_res)^2)/((res_resample_from)^2)))

    # resample to the new resolution
    unit_pop_raster_crp_resamp <- raster::resample(unit_pop_raster_crp, sh_admin_int_shp_unprocessed_rasterized, method = "ngb")

    # mask resampled pol raster to the cur unprocessed shr id
    unit_pop_raster_crp_resamp_msk <- raster::mask(unit_pop_raster_crp_resamp, sh_admin_int_shp_unprocessed_rasterized)

    region_raster_brick_resample <- stack(sh_admin_int_shp_unprocessed_rasterized, unit_pol_raster_crp_resamp_msk, unit_pop_raster_crp_resamp_msk)
    names(region_raster_brick_resample) <- c("sh_rast", "pol_rast", "pop_rast")

    region_raster_brick_df_resample <- raster::as.data.frame(region_raster_brick_resample, na.rm = TRUE) %>%
      filter(!is.na(pol_rast) & !is.na(pop_rast))

    region_raster_brick_df_arrow_resample <- as_arrow_table(region_raster_brick_df_resample)
    region_raster_brick_df_arrow_collapse_resample <- region_raster_brick_df_arrow_resample %>%
      group_by(sh_rast) %>%
      collect() %>%
      mutate(pop_weights = pop_rast / sum(pop_rast, na.rm = TRUE),
             pollution_pop_weighted = pop_weights * pol_rast) %>%
      summarise(total_population = sum(pop_rast, na.rm = TRUE),
                avg_pm2.5_pollution = sum(pollution_pop_weighted, na.rm = TRUE)) %>%
      ungroup()

    return(region_raster_brick_df_arrow_collapse_resample)
  })
}


#' Process Uncaptured UIDs for Population-Weighted PM2.5 Calculation
#'
#' This function processes regions (UIDs) that were not captured during the initial population-weighted
#' PM2.5 calculation. It resamples both the population and pollution rasters to a finer resolution,
#' rasterizes the corresponding shapefile regions, and computes the population-weighted average PM2.5 values.
#'
#' @param uids_not_captured A vector of unique identifiers (`uid_for_rasterization`) corresponding to regions
#' that were not captured in the initial processing.
#' @param unit_pol_raster A `RasterLayer` of unit-level PM2.5 pollution values.
#' @param unit_pop_raster A `RasterLayer` of unit-level population values, typically at coarser resolution.
#' @param ref_shp_file_to_be_rasterized A `sf` object containing the shapefile with administrative boundaries
#' and a column `uid_for_rasterization` used for rasterization.
#' @param resample_to_res A numeric value indicating the target resolution (in degrees) to which both the
#' pollution and population rasters will be resampled. Defaults to 0.0005.
#' @param res_resample_from A numeric value indicating the original resolution (in degrees) of the
#' population raster. Defaults to 0.00833333 (approximately 1km).
#'
#' @return A data frame with one row per successfully processed UID, containing:
#' \describe{
#'   \item{sh_rast}{The UID of the processed region.}
#'   \item{total_population}{Total population within the region after resampling.}
#'   \item{avg_pm2.5_pollution}{Population-weighted average PM2.5 value for the region.}
#' }
#'
#' @details
#' The function performs the following for each UID:
#' \itemize{
#'   \item Filters the shapefile to the current UID.
#'   \item Rasterizes the shapefile region at the specified finer resolution.
#'   \item Resamples the pollution and population rasters to match this new resolution.
#'   \item Converts the raster data to a data frame.
#'   \item Calculates population weights and weighted pollution.
#'   \item Aggregates to obtain population-weighted PM2.5 values.
#' }
#' This is useful for recovering data for small or sparsely populated regions that were dropped due to
#' mismatches or resolution limitations in the initial processing.
#'
#' @importFrom dplyr filter mutate summarise group_by ungroup bind_rows
#' @importFrom purrr map_dfr
#' @importFrom raster crop mask resample extent crs stack as.data.frame values
#' @importFrom fasterize fasterize
#' @importFrom arrow as_arrow_table
#' @importFrom tictoc tic toc
#'
#' @export


process_uncaptured_uids_v2 <- function(uids_not_captured, unit_pol_raster, unit_pop_raster, ref_shp_file_to_be_rasterized, resample_to_res = 0.0005, res_resample_from = 0.00833333) {

  map_dfr(uids_not_captured, function(uid) {
    cat(sprintf("Processing UID: %d\n", uid))
    tic()
    sh_admin_int_shp_unprocessed <- ref_shp_file_to_be_rasterized %>%
      filter(uid_for_rasterization %in% uids_not_captured_master_r1)

    sh_admin_int_shp_unprocessed_rasterized <- fasterize(sh_admin_int_shp_unprocessed, raster(ext = extent(sh_admin_int_shp_unprocessed), resolution = resample_to_res, crs = crs(sh_admin_int_shp_unprocessed)), field = "uid_for_rasterization", fun = "last")

    tic()
    unit_pol_raster_crp_resamp_msk <- crop(unit_pol_raster, sh_admin_int_shp_unprocessed_rasterized) %>%
      resample(sh_admin_int_shp_unprocessed_rasterized, method = "ngb") %>%
      mask(sh_admin_int_shp_unprocessed_rasterized)
    toc()


    unit_pop_raster_crp <- crop(unit_pop_raster, sh_admin_int_shp_unprocessed_rasterized)

    # replace population values with population densities before resampling
    raster::values(unit_pop_raster_crp) <- as.vector(unit_pop_raster_crp * (((resample_to_res)^2)/((res_resample_from)^2)))

    # resample to the new resolution
    unit_pop_raster_crp_resamp <- raster::resample(unit_pop_raster_crp, sh_admin_int_shp_unprocessed_rasterized, method = "ngb")

    # mask resampled pol raster to the cur unprocessed shr id
    unit_pop_raster_crp_resamp_msk <- raster::mask(unit_pop_raster_crp_resamp, sh_admin_int_shp_unprocessed_rasterized)

    region_raster_brick_resample <- stack(sh_admin_int_shp_unprocessed_rasterized, unit_pol_raster_crp_resamp_msk, unit_pop_raster_crp_resamp_msk)
    names(region_raster_brick_resample) <- c("sh_rast", "pol_rast", "pop_rast")

    region_raster_brick_df_resample <- raster::as.data.frame(region_raster_brick_resample, na.rm = TRUE) %>%
      filter(!is.na(pol_rast) & !is.na(pop_rast))

    region_raster_brick_df_arrow_resample <- as_arrow_table(region_raster_brick_df_resample)
    region_raster_brick_df_arrow_collapse_resample <- region_raster_brick_df_arrow_resample %>%
      group_by(sh_rast) %>%
      collect() %>%
      mutate(pop_weights = pop_rast / sum(pop_rast, na.rm = TRUE),
             pollution_pop_weighted = pop_weights * pol_rast) %>%
      summarise(total_population = sum(pop_rast, na.rm = TRUE),
                avg_pm2.5_pollution = sum(pollution_pop_weighted, na.rm = TRUE)) %>%
      ungroup()

    toc()

    return(region_raster_brick_df_arrow_collapse_resample)
  })
}





#' Process Population-Weighted PM2.5 Pollution Data for a Given Year
#'
#' Computes average population-weighted PM2.5 pollution levels at a specified administrative level
#' using yearly pollution and population rasters, and a shapefile to rasterize for regional identification.
#'
#' @param pol_raster_path File path to the NetCDF (.nc) raster containing PM2.5 pollution data for a specific year.
#' @param ref_admin_level_shp_file A spatial object (e.g., `sf` or `sp`) representing the reference administrative boundaries for cropping and masking.
#' @param ref_shp_file_to_be_rasterized A spatial object with a column named `uid_for_rasterization` to be rasterized and used for aggregation.
#' @param unit_pop_raster A raster object representing the population data (e.g., at 1 km resolution).
#' @param unit_pop_raster_crp_msk A cropped and masked version of the population raster aligned with the reference shapefile.
#'
#' @return A data frame with administrative region identifiers (`sh_rast`), total population, and average population-weighted PM2.5 pollution
#' for the year extracted from the filename.
#'
#' @details The function performs the following steps:
#' \enumerate{
#'   \item Loads and preprocesses the pollution raster from NetCDF.
#'   \item Crops and masks the pollution raster to the reference shapefile.
#'   \item Resamples the pollution raster to match the resolution of the population raster.
#'   \item Rasterizes the reference shapefile using `uid_for_rasterization`.
#'   \item Combines pollution, population, and region rasters into a brick, converts to a data frame, and calculates population weights.
#'   \item Computes population-weighted pollution averages by region.
#'   \item Identifies and attempts to reprocess regions with missing or zero data.
#'   \item Returns a final data frame with cleaned and complete population-weighted pollution estimates.
#' }
#'
#' @seealso \code{\link{nc_to_raster_layer}}, \code{\link{matchResolution}}, \code{\link{fasterize}}, \code{\link{process_uncaptured_uids}}
#'
#' @export


process_yearly_raw_pop_weighted_pol <- function(pol_raster_path, ref_admin_level_shp_file, ref_shp_file_to_be_rasterized, unit_pop_raster, unit_pop_raster_crp_msk) {
  cur_rast_year <- as.numeric(str_remove(str_extract(pol_raster_path, "\\d+\\.nc"), "12.nc"))
  cat(sprintf("%d pm2.5 pol data processing starts!\n", cur_rast_year))

  print("start processing")
  # Load and preprocess the pollution raster
  unit_pol_raster <- nc_to_raster_layer(pol_raster_path, "PM25", "latitude", "longitude")
  unit_pol_raster_crp_msk <- unit_pol_raster %>%
    crop(ref_admin_level_shp_file) %>%
    mask(ref_admin_level_shp_file)

  print("pol raster cropped masked")

  # Preprocess the population raster
  # unit_pop_raster_crp_msk <- unit_pop_raster %>%
  #   crop(ref_admin_level_shp_file) %>%
  #   mask(ref_admin_level_shp_file)

  print("pop raster cropped masked")

  # Match the resolution of the pollution raster to the population raster
  unit_pol_raster_crp_msk <- matchResolution(unit_pol_raster_crp_msk, unit_pop_raster_crp_msk)

  print("matched pop pol res")
  # Rasterize the reference shapefile
  sh_admin_int_shp_rasterized <- fasterize(ref_shp_file_to_be_rasterized, unit_pol_raster_crp_msk, field = "uid_for_rasterization", fun = "last")

  print("rasterized shp file")

  # Create a raster brick
  region_raster_brick <- stack(sh_admin_int_shp_rasterized, unit_pol_raster_crp_msk, unit_pop_raster_crp_msk)
  names(region_raster_brick) <- c("sh_rast", "pol_rast", "pop_rast")

  # Convert the raster brick to a dataframe
  region_raster_brick_df <- raster::as.data.frame(region_raster_brick, na.rm = TRUE) %>%
    filter(!is.na(pol_rast) & !is.na(pop_rast))

  print("raster brick created")

  # Convert to arrow table and collapse
  region_raster_brick_df_arrow <- as_arrow_table(region_raster_brick_df)
  region_raster_brick_df_arrow_collapse <- region_raster_brick_df_arrow %>%
    dplyr::group_by(sh_rast) %>%
    dplyr::collect() %>%
    dplyr::mutate(pop_weights = pop_rast / sum(pop_rast, na.rm = TRUE),
                  pollution_pop_weighted = pop_weights * pol_rast) %>%
    dplyr::summarise(total_population = sum(pop_rast, na.rm = TRUE),
                     avg_pm2.5_pollution = sum(pollution_pop_weighted, na.rm = TRUE)) %>%
    dplyr::ungroup()

  print("data collapsed at admin region level")
  # Identify uncaptured UIDs
  uids_not_captured <- setdiff(ref_shp_file_to_be_rasterized$uid_for_rasterization, region_raster_brick_df_arrow_collapse$sh_rast)

  # Identify UIDs with NA population, NA pollution, and zero population
  uids_with_na_pop <- region_raster_brick_df_arrow_collapse %>%
    dplyr::filter(is.na(total_population)) %>%
    dplyr::pull(sh_rast)

  uids_with_na_pol <- region_raster_brick_df_arrow_collapse %>%
    dplyr::filter(is.na(avg_pm2.5_pollution)) %>%
    dplyr::pull(sh_rast)

  uids_with_zero_pop <- region_raster_brick_df_arrow_collapse %>%
    dplyr::filter(total_population == 0) %>%
    dplyr::pull(sh_rast)

  # Combine all uncaptured UIDs
  uids_not_captured_master_r1 <- unique(c(uids_not_captured, uids_with_na_pop, uids_with_na_pol, uids_with_zero_pop))

  print("all uncaptured uids stored in a vector")

  print("start capturing unprocessed ids")
  # Process uncaptured UIDs
  if (length(uids_not_captured_master_r1) > 0) {
    resample_obj_capture_list <- process_uncaptured_uids(uids_not_captured_master_r1, unit_pol_raster, unit_pop_raster, ref_shp_file_to_be_rasterized)

    # the zero pop uids are were attempted to be recaptured in the step above, so removing from the original df to avoid double counting before binding rows
    region_raster_brick_df_arrow_collapse <- region_raster_brick_df_arrow_collapse %>%
      filter(total_population != 0)
    # bind originally captured and unprocessed recaptured
    region_raster_brick_df_arrow_collapse <- bind_rows(region_raster_brick_df_arrow_collapse, resample_obj_capture_list)
  }

  print("captured unprocessed ids")

  # Rename the pollution column
  colnames(region_raster_brick_df_arrow_collapse)[colnames(region_raster_brick_df_arrow_collapse) == "avg_pm2.5_pollution"] <- sprintf("avg_pm2.5_%d", cur_rast_year)

  cat(sprintf("%d pm2.5 pol data processing completed!\n", cur_rast_year))
  return(region_raster_brick_df_arrow_collapse)

  print("done!")
}










#' Split a List into Chunks
#'
#' Divides a list into smaller sublists (chunks) of approximately equal size.
#'
#' @param lst A list to be split.
#' @param n An integer specifying the size of each chunk (i.e., the maximum number of elements in each sublist).
#'
#' @return A list of lists, where each sublist contains at most \code{n} elements from the original list.
#'
#' @examples
#' chunk_list(as.list(1:10), 3)
#' chunk_list(list("a", "b", "c", "d", "e"), 2)
#'
#' @export

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
