
# biteSizedVisual \#6: Which pollutant sets India’s air quality index, month by month

Discussion of air quality in India usually centers on PM2.5
concentrations, and for good reason: PM2.5 or fine particulate matter
are particles that are small enough to reach deep into the lungs and
enter the bloodstream, and are among the pollutants most strongly linked
to ill health. This post looks at a narrower and more specific thing
that the daily data records — not how harmful the air is, but which
pollutant is registered as setting the index each day, and how that
varies through the year.

## The data

The source is the CPCB’s daily national AQI bulletin, compiled by
UrbanEmissions.info into a single table: roughly 470,000 rows spanning 1
May 2015 to 31 December 2025, one row per city per day, across 297
cities. Each row records six fields — the date, the city, the number of
monitoring stations behind that day’s reading, the AQI value (on the
0–500 scale), the AQI category (Good, Satisfactory, Moderate, Poor, Very
Poor, Severe), and the prominent pollutant. It is that last field this
post is built on.

Two things are worth keeping in mind. The bulletin reports the AQI — an
index value — not raw pollutant concentrations in µg/m³. And coverage
grows over the period: far more cities report in later years — from a
couple of dozen in 2015 to nearly 290 by 2025 — though the typical city
reports from just a few (very often one or two stations and mostly less
than 10) throughout, so a city’s daily value is more often than not
based on very few monitors. There are some exceptions where a city’s
value may be driven by more than 10 monitors, but those are rare cases.

## What “prominent pollutant” means

The AQI is the single number reported each day for a city — “AQI 180,”.
It is built from several pollutants that monitors measure in the air:
fine particles (PM2.5), coarse dust (PM10), ozone, carbon monoxide and a
few others.

Here is the key idea. ***Each pollutant has its own safe limit***, and
those limits differ because some pollutants are more dangerous than
others. Each one is then given a score for how far past its own safe
level it is that day, on a shared scale where the same score means the
same level of health concern no matter which pollutant it came from.
***The AQI for the day is just the worst of those scores — and the
pollutant with that worst score is called the prominent pollutant***.
***That is the field this post follows.***

The catch is that “worst score” is not the same as “most of it.” Picture
a day with only a little PM2.5 but more PM10 by weight. Because fine
particles are more harmful than coarse dust, even the smaller amount of
PM2.5 can score worse — so PM2.5 becomes the prominent pollutant, even
though there was more PM10 in the air. It set the day’s index by being
the most dangerous relative to its own limit, not by being the most
abundant.

And “prominent” is not a measure of overall harm. How harmful a day’s
air is depends on all the pollutants in it together — that is a separate
question this blog does not answer. The prominent pollutant simply picks
out the single one that scored worst; it says nothing about the others
that were also in the air. PM2.5, for instance, is generally considered
more harmful to health than PM10 whenever both are around — regardless
of how often it happens to be the one setting the index.

With that in mind, here is what the field records across the eleven
years.

## What the data shows

First, how to read these numbers. Everything is counted in *city-days* —
one city on one day — and each city-day is tagged with the pollutant
that topped its air that day. A pollutant’s “share” for a month is
simply the fraction of that month’s city-days it topped. And because we
pool all eleven years, “January” means every city’s readings from all
the Januaries between 2015 and 2025 taken together. So “PM2.5 has a 58%
share in January” reads as: across all those January city-days between
2015 AND 2025, PM2.5 was the worst pollutant In 58% of those days.

Across the whole period (2015–2025), pooling every city and day and
splitting credit on the days that name more than one prominent
pollutant:

- **Overall,** PM10 is recorded as the prominent pollutant on about
  **49%** of all city-days, **PM2.5** on about **32%**, ozone on about
  **9%** and CO on about **7%**, with the rest below that.

- **By season** (still pooling all eleven years) — Winter
  (December–February), Summer (March–June), Monsoon (July–September),
  Post-monsoon (October–November): PM2.5 is prominent most often in
  winter, about **52%** of winter city-days, and — by a small margin —
  in the post-monsoon (leading to the winter); PM10 leads across the
  summer and monsoon, over half of city-days in each. Ozone is at its
  most prominent in the summer heat and CO in the monsoon, though PM10
  still leads in both.

- **Month by month** — the level the charts actually show, each calendar
  month pooled across all eleven years (2015–2025) — PM2.5’s share of
  prominent days peaks in January (with December close behind), PM10’s
  around April, ozone’s in May, and CO’s in July and August.

These are counts of how often each pollutant sets the index, not
statements about which pollutant is most present or most harmful in
general.

## Possible reasons for the pattern

The seasonal movement is consistent with several known processes, though
the data here only shows the pattern, not the cause:

- **Cold months (PM2.5).** Lower temperatures, weaker mixing and
  temperature inversions can trap combustion emissions near the ground,
  and this period overlaps with crop-residue burning in the north —
  conditions under which fine particles may register as prominent more
  often.

- **Summer and pre-monsoon (PM10, then ozone).** Dry, dusty, windy
  conditions can raise coarse dust from soil, roads and construction,
  while strong sunshine and heat favour the photochemical formation of
  ozone.

- **Monsoon (CO).** Rain scavenges particulate matter from the air, so
  PM sub-indices tend to fall. A pollutant like CO can therefore become
  the *prominent* one without its own levels rising — a reminder that a
  shift in prominence can reflect other pollutants declining as much as
  that one increasing.

## Two views

The same summary is shown two ways. Both run December to November so the
seasons form unbroken blocks, with the season name bracketed under the
months.

The **stacked bar** is best for reading a single month and comparing
months. Each month is a full-height bar sliced into colored blocks, one
per pollutant, and the size of a block is that pollutant’s share of the
month’s city-days (from 2015 to 2025). For example, the January bar is
mostly blue (PM2.5), but slide across to April and it is mostly orange
(PM10) — the winter-to-summer hand off shows up as the blue block
shrinking and the orange one growing.

![](images/india_pollutant_by_month_bar.png)

The **stacked area** shows the same shares as bands that flow across the
year, so you can follow one pollutant’s rise and fall. Trace the blue
PM2.5 band, for example: it is widest in the winter months on the left,
narrows to its thinnest across the monsoon in the middle, then widens
again toward the post-monsoon on the right, approaching winter months
againn. I suppose there are better ways to plot the cyclical nature, but
you can read it as post Nov in the right, we circle back to Dec in the
far left.

![](images/india_pollutant_by_month_area.png)

## How the data is transformed

The chart is several steps removed from the raw table and below I have
explained how transformations have been performed.

First, from text to pollutants. The prominent-pollutant field sometimes
names one pollutant and sometimes several (e.g. “PM10, PM2.5”). I
standardise the pollutant names and split multi-pollutant entries into
their individual pollutants, so each city-day is associated with one or
more prominent pollutants. Rows missing a date, city, or AQI value are
dropped.

Second, from pollutants to a count. Each city-day contributes one unit
of “credit” to the prominent pollutant it names. On the roughly 12% of
city-days that list more than one prominent pollutant, that unit is
split evenly among them — a two-pollutant day gives half to each —
rather than handing the whole day to whichever was listed first. The
bulletin’s ordering is not a stated ranking, so splitting evenly avoids
reading a hierarchy into it that may not be there.

Third, from counts to monthly shares. I then pool every city and every
year, total the credit for each pollutant within each calendar month,
and express it as a percentage of that month’s total. That is the
summary table the charts are drawn from: twelve months, each summing to
100%, giving the share of city-days on which each pollutant was
prominent.

A few simplified assumptions are implicit in that summary, so I am
stating them here clearly:

- **A city-day is the unit.** Every city counts equally on each day it
  reports — a large metro and a small town carry the same weight, and
  neither population nor the number of stations enters the calculation.
  Cities that report more often contribute more to the totals.

- **Years are pooled.** **Years are pooled.** The twelve months combine
  all of 2015–2025 into a single average year, so the charts show a
  typical seasonal pattern rather than a trend. For example, PM10’s
  “July” share is the number of city-days across all eleven Julys
  (2015–2025) on which PM10 was prominent, divided by the total July
  city-days over those same eleven years — pooled together, not averaged
  year by year.

- **Credit is split evenly on shared days**, as above — no ordering or
  ranking is inferred from multi-pollutant entries.

- **Season boundaries are fixed.** Months are grouped Winter (Dec–Feb),
  Summer (Mar–Jun), Monsoon (Jul–Sep), Post-monsoon (Oct–Nov); other
  conventions, such as the IMD’s, may draw the season lines slightly
  differently.

- **Changing coverage is not adjusted for.** Because many more cities
  report in later years, the pooled average leans somewhat toward the
  network as it looked more recently.

The full pipeline: reading the source CSV, cleaning it, building this
summary table, and drawing the charts — runs in a single Rmd script, so
any of these choices can be changed and the results regenerated. Here is
a [link to access that
Rmd](https://github.com/AarshBatra/biteSizedAQ/blob/main/30.bite.sized.vis.6.india.aq.pollutants.season.trends.Rmd).

## Data Credit

*Data: CPCB daily AQI bulletins, compiled by UrbanEmissions.info (*GNU
General Public License v3.0*), [Link](#0). See License and Reuse
section.*

## Support This Work: Give It a Star

Thank you for reading! If you found this project helpful or interesting,
please consider starring it on GitHub. Your stars help others discover
and benefit from this fully open and free repository. Click [here to
star the
repository](https://github.com/AarshBatra/biteSizedAQ/stargazers) and
join other folks who follow biteSizedAQ.

## License and Reuse

All content under **biteSizedAQ** is shared under the **Creative Commons
Attribution 4.0 International (CC BY 4.0)** license, ***with the
exception*** of specific components noted below. You are welcome to use
the CC BY 4.0 material in your reports or news stories—just remember to
give appropriate credit and include a link back to the original work.

- **GPL-3.0 Components:** The *UrbanEmissions.info* compiled data used
  in this project contains data licensed under the **GNU General Public
  License v3.0 (GPL-3.0)**. In accordance with this license, the source
  code and modifications for this specific component are made available
  \[here\]. Any derivative works of this component must also be licensed
  under the GPL-3.0.

Every effort is made to ensure that only original or appropriately
licensed material is shared. If any copyrighted content has been used
inadvertently, please note that this is unintentional, and I will
promptly address it upon notification.

Thank you for respecting these terms!

## Get in touch

Get in touch about related topics/report any errors. Reach out to me at
bitesizedaq@gmail.com.
