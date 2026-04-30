# README - A dataset of harmonized global air quality monitoring metadata - METAIR

Product Name = METAIR
Version = 1.0
Title = A dataset of harmonized global air quality monitoring metadata 
Dataset Location = www.doi.org/10.5281/zenodo.1568086
Created Time = June 2025 
Release date = December 2025
Number of Rows = 14970
Number of Columns = 10
FillValue = nan
License = Creative Commons Attribution 4.0 International -- CC BY 4.0 


## Contact Information 

Stefania Renna, Politecnico di Milano, RFF-CMCC European Institute on Economics and the Environment, stefania.renna@polimi.it, stefania.renna@cmcc.it
Please contact us for any information. Suggestions or corrections to the provided data are encouraged.


## Abstract

This study addresses the gap in air quality monitoring metadata reporting by building a classifier for air quality station types and area characteristics. It leverages ultra-high-resolution land cover data, complemented by additional demographic and gridded information. We employ advanced machine learning methods, including convolutional neural networks and transformers. Through a custom training approach, we fine-tune pre-trained models on approximately 7000 images and label more than 8000 additional monitors, resulting in a robust model for classifying air quality stations by area characteristics (urban, rural) and source type (background, non-background). The result is the first global harmonized dataset of governmental air quality station metadata for particulate matter, with about 15000 monitors from more than 100 countries. For each air quality station, the dataset provides an identifier, geographical coordinates, the associated country, area characteristics, source type, and classification status. This dataset enables global feasibility studies and regional analyses of conditions leading to exposure. By providing a consistent classification of monitoring stations, it also allows for meaningful comparisons of sectoral exposure contributions across countries, regions, and station types, supporting comparative studies and health impact assessments.


## Variable list (dataset_v_1.csv)

unique_id = identifier identifies the air quality station (categorical)
pollutant =a categorical variable names the pollutant measured at such station (categorical)
iso =a three-letter country ISO code (\texttt{iso}) locates it nationally (categorical)
longitude = its World Geodetic System 1984 (WGS84) geographic coordinates in degrees 
latitude = its World Geodetic System 1984 (WGS84) geographic coordinates in degrees 
elevation = elevation in meters (numeric)
area = air quality station area characteristics (urban, rural)
type = air quality station type (background, non-background)
labeled_area = binary flag indicating whether the air quality station area characteristics classifications has been directly attributed by an institutional agency such as a governmental air quality network (1) or estimated by our model (0)
labeled_type = binary flag indicating whether the air quality station type classifications has been directly attributed by an institutional agency such as a governmental air quality network (1) or estimated by our model (0)


## Data inputs

All input sources are openly available for download online or by request to the competent authority. 

### Land cover
- ESA WorldCover 10 m 2021 v200 product (Zanaga et al., 2022). Product User Manual at: 
https://worldcover2021.esa.int/data/docs/WorldCover_PUM_V2.0.pdf

### Air Quality Station Metadata
- Australia: files downloaded from API (see https://www.environment.nsw.gov.au/topics/air/monitoring-air-quality)
- Brazil: specific file downloaded from https://energiaeambiente.org.br/qualidadedoar/en/
- Canada: specific file downloaded from https://data-donnees.az.ec.gc.ca/data/air/monitor/national-air-pollution-surveillance-naps-program/ProgramInformation-InformationProgramme/?lang=en
- China: http://www.cnemc.cn
- EEA: specific file downloaded from https://discomap.eea.europa.eu/App/AQViewer/index.html?fqn=Airquality_Dissem.b2g.measurements
- Mexico: https://sinaica.inecc.gob.mx/ 
- Mexico City: http://www.aire.cdmx.gob.mx/
- Japan: specific yearly files downloaded from https://tenbou.nies.go.jp/download/
- New Zealand: integrated into the data files, available at https://www.lawa.org.nz/download-data#air. Note: no "background" category
- South Africa: specific file provided by the national authority
- US: specific files downloaded from https://aqs.epa.gov/aqsweb/airdata/download_files.html#Meta
- OpenAQ: files downloaded from API (https://openaq.org/)

### Air pollution
- High-resolution estimates of PM2.5 and CO from the Global High-Resolution Air Pollution (GHAP) datasets are available at https://www.doi.org/10.5281/zenodo.10800980 and https://www.doi.org/10.5281/zenodo.14207363
- Annual global sectoral emission emissions data of CAMS-GLOB-ANT v 6.2 for black carbon, sulfur dioxide, non-methane volatile organic compounds, and ammonia are available at https://eccad.aeris-data.fr/

### Industrial sources
- Global Power Plant Database released by the Global Energy Observatory (http://datasets.wri.org/dataset/globalpowerplantdatabase)
- Global Coal Plant Tracker (July 2023 release) by Global Energy Monitor (https://globalenergymonitor.org/)
- Global Coal Mine Tracker (October 2023 release) by Global Energy Monitor (https://globalenergymonitor.org/)
- Global Oil and Gas Plant Tracker (August 2023 release) by Global Energy Monitor (https://globalenergymonitor.org/)
- Global Steel Plant Tracker (March 2023 release) by Global Energy Monitor (https://globalenergymonitor.org/)
- Global Bioenergy Power Tracker V1 (November 15, 2023 release) by Global Energy Monitor (https://globalenergymonitor.org/)
- The Global Database of Cement Production Assets and Upstream Suppliers (https://doi.org/10.5061/dryad.6t1g1jx4f)
- The EEA European Pollutant Release and Transfer Register (https://sdi.eea.europa.eu/catalogue/srv/api/records/9405f714-8015-4b5b-a63c-280b82861b3d)

### Annual population
- High-resolution population density from the Gridded population of the world, v 4 (GPWv4): Population density, revision 11 (https://doi.org/10.7927/H49C6VHW)


## Scripts description

The code is structured in multiple parts under the /code/ folder or sub-directories. 
Working on PyCharm Professional 2022.3.3, Python 3.9.18

---

To replicate the models:

- Go to the modeling_code/ folder
- Install requirements as pip install -r requirements.txt
- Change the paths in train_integrated_model.py to the local path of the user
- Run train_integrated_model.py
- Input data: metadata_final.csv, labeled images in labeled.zip, unlabeled images in unlabeled.zip


To replicate the input to the models: 

- Go to the input_code/ folder
- Install requirements as pip install -r input_requirements.txt
- Run code.py
- Input data are freely downloadable online

---

Code detail:

**`/code/scripts/input_requirements.txt`**
Text file with requirements to be installed as: pip install -r input_requirements.txt

**`/code/scripts/context.py`**
Functions for path handling and DataFrame display settings across multiple scripts.

**`/code/scripts/metadata/air_quality_stations_metadata/openaq_data.py`** 
Script for retrieving the locations of air quality stations monitoring PM (both PM2.5 and PM10) provided by governmental 
institutions available on OpenAQ.
The output file `data/in/air_quality_stations_govt_openaq.csv` contains the list of air quality stations retrieved from 
OpenAQ for countries from the following continents: Africa, Asia, America, Oceania.

**`/code/scripts/metadata/worldcover.py`** 
Functions for downloading WorldCover land cover data. 

**`/code/scripts/metadata/industrial_metadata/industrial_plants.py`** 
Script that puts together industrial plants databases, and proxies additional chemical plants through industrial
emissions from relevant pollutants (NOx, SO2, NH3, VOCs). 
Specifically, waste power plants, biomass power plants, coal and coal mine plants, 
oil and gas plants, steel plants, bioenergy power plants, and cement production sites. 
Only operating plants are considered.
Sources are the following: 
- the Global Power Plant Database,
- the Global Coal Plant Tracker, 
- the Global Coal Mine Tracker,
- the Global Oil and Gas Plant Tracker, 
- the Global Steel Plant Tracker, 
- the Global Bioenergy Power Tracker,
- the Global Database of Cement Production Assets and Upstream Suppliers,
- the European Pollutant Release and Transfer Register (E-PRTR),
- the CAMS-GLOB-ANT data set.

**`/code/scripts/metadata/air_quality_stations_metadata/{iso}_metadata.py`** 
Script for harmonizing metadata for specific countries.
Note: in Europe, suburban areas classified as urban.
iso = {'eea', 'can', 'jpn', 'usa', 'zaf', 'chn', 'aus', 'bra', 'ind', 'omn', 'pji', 'mex', 'qat', 'kor', 'tha'}

**`/code/scripts/metadata/merge_metadata.py`** 
Script for merging the harmonized air quality station metadata.
Saves `metadata_type_unique.csv`.

**`/code/scripts/metadata/download_worldcover.py`** 
Set of functions for downloading WorldCover land cover data as arrays.
See https://github.com/ESA-WorldCover/esa-worldcover-datasets/tree/main for reference.
Note: raw data (folder 'classified') moved to external disk.

**`/code/scripts/metadata/crop_worldcover.py`** 
Set of functions for downloading WorldCover land cover data as images.
Note: raw data needed to run it (folder 'classified') moved to external disk.

**`/code/scripts/metadata/air_pollution_metadata/interpolated_annual_ghap.py`** 
Script that: 
- applies bilinear interpolation to 1-km annual global GHAP estimates to get
an interpolated value of PM2.5 at the air quality stations locations.
- attributes the 1 km annual global PM2.5 GHAP estimate cell value in which the station location
falls.
Saves file `metadata_type_bilinear_pm25_cell_pm25.csv`.

**`/code/scripts/metadata/population_metadata/annual_pop_density.py`**
Script that attributes the 1-km annual population density cell value in which the station location
falls.
Saves file `metadata_type_bilinear_pm25_cell_pm25_pop_density.csv`

**`/code/scripts/metadata/emission_metadata/annual_emissions.py`** 
Script that attributes to the station the CAMS-GLOB-ANT v6.2 10 km annual sectoral emission values for 2022 in which the station is located.
Sectors: "awb", "com", "ene", "fef", "ind", "ref", "res", "shp", "sum", "tnr", "tro".
Emissions in Tg.
Saves file `metadata_type_bilinear_pm25_cell_pm25_cell_pop_density_cell_emi.csv`.

**`/code/scripts/metadata/air_pollution_metadata/annual_ghap_co.py`**
Script that attributes the 1 km annual global CO GHAP estimate cell value in which the station location
falls.
Saves file `metadata_type_bilinear_pm25_cell_pm25_cell_pop_density_cell_emi_cell_co.csv`.

**`/code/scripts/plots/plots.py`**
Script for plotting images.

**`/code/scripts/tables/tables.py`**
Script that creates air quality stations' descriptives tables.

**`/code/scripts/metadata/dataset.py`**
Script that creates the final metadata file and supplementary files.


## Technical details

For more information, e.g., on the methodology, please consult the related manuscript "A dataset of harmonized global air quality monitoring metadata".