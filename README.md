
<!-- README.md is generated from README.Rmd. Please edit that file -->

# biteSizedAQ

<!-- badges: start -->
<!-- badges: end -->

## Background

Air pollution can feel like a giant, overwhelming issue, but the goal of
this project is to make air quality (AQ) information accessible and
understandable for everyone. The name ‘biteSizedAQ’ serves as a reminder
that even the largest problems can be tackled with small, manageable
steps. Instead of feeling overwhelmed, we can break down the air
pollution challenge into smaller tasks, taking each one step at a time.
By consistently taking these bite-sized, smart steps, we can
collectively make significant progress in managing air pollution.

All projects under this repository are free and open, provided under the
CC BY 4.0 International License. This ensures that anyone can use,
share, and build upon the work, making air quality information more open
and accessible for all.

This repository will continue to grow with new projects as and when I
find time. To kick things off, check out the first project: using
satellite-derived air pollution and population data, combined with
India’s block (subdistrict) level shapefile, we’ve created a detailed
air pollution dataset at the block level. Explore the details below to
learn more.

Upcoming potential projects include producing satellite-derived PM2.5
data at the village level for over 600,000 Indian villages. Star the
repo to keep track of updates.

## General structure and how to navigate projects in this repo

- Each individual project correspond to it’s own Rmd file, which can be
  found at the root of the repo.

- The project’s unique folder of the same name as the Rmd also exists at
  the root of the repo.

- The number prefix at the start of every project folder/Rmd name is the
  project id under this repo.

- The corresponding helper R script(s) for different projects can be
  found under `R/` subfolder. These scripts will be grouped in broad
  themes. E.g. all satellited derived data processing functions will be
  in the sat data helper script and the names are descriptive enough for
  it to be easily identifiable.

- The latest project will show up top.

- E.g. Project 1 has the id 1. It corresponds to a Rmd file named
  `1.ind.block.pm2.5.sat.data.processing.Rmd`, a project folder named
  `1.ind.block.pm2.5.sat.data.processing` and corresponding helper
  functions can be found in the helper scripts in the `R/` subfolder.

## Project 1: Block level satellite derived population weighted air pollution dataset for India from 1998-2022

- Read more about this project and download proccessed data from
  [here](https://github.com/AarshBatra/biteSizedAQ/tree/main/1.ind.sat.data.processing).
  This folder is present at the root of the repo.

- Data Processing pipeline Rmd file for this project: Also, present at
  the root of the repo. Here is a [quick link to access the
  pipeline](https://github.com/AarshBatra/biteSizedAQ/blob/main/1.ind.block.pm2.5.sat.data.processing.Rmd).
