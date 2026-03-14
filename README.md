# US City Crime Dashboard — R Shiny

An interactive R Shiny dashboard exploring violent crime trends across 68 major US cities from 1975 to 2015, built using data from [The Marshall Project](https://github.com/themarshallproject/city-crime).

This is an individual reimplementation of the [group Python Shiny project](https://github.com/UBC-MDS/DSCI-532_2026_38_crime-dashboard) for DSCI 532.

---

## Deployed App

👉 **[View the live dashboard]((https://019ced30-0d4c-9392-105c-8d421d9b46a2.share.connect.posit.cloud/))**

---

## Dashboard Preview

![Crime Dashboard Preview](img/preview.png)

---

## Features

- **Crime type selector** — switch between total violent crime, homicide, rape, robbery, or assault (all rates per 100,000 residents)
- **Year range slider** — filter the data to any window between 1975 and 2015
- **City selector** — highlight up to 10 cities on the trend chart
- **Trend line chart** — compare how selected cities changed over time
- **Top 15 cities bar chart** — see which cities averaged the highest rates in the selected period
- **Summary value boxes** — quick stats on cities tracked, years selected, and national average
- **Interactive data table** — browse and search the underlying filtered data

---

## How to Run Locally

### 1. Prerequisites

Make sure you have R (≥ 4.2) installed. You can download it from [cran.r-project.org](https://cran.r-project.org/).

RStudio is recommended but not required: [posit.co/download/rstudio-desktop](https://posit.co/download/rstudio-desktop/).

### 2. Clone the repository

```bash
git clone https://github.com/dianadadkhah/crime-dashboard-r.git
cd crime-dashboard-r
```

### 3. Install R packages

Open R or RStudio and run:

```r
install.packages(c(
  "shiny",
  "bslib",
  "bsicons",
  "dplyr",
  "ggplot2",
  "DT"
))
```

> **Note:** The data is loaded automatically from the Marshall Project's public GitHub repository — no manual data download is needed.

### 4. Run the app

#### Option A — from the R console

```r
shiny::runApp("app.R")
```

#### Option B — from the terminal

```bash
Rscript -e "shiny::runApp('app.R')"
```

#### Option C — in RStudio

Open `app.R` and click the **Run App** button.

---

## Dependency File (for Posit Connect Cloud)

This repo includes an `renv.lock` file for reproducible deployment on Posit Connect Cloud.

To regenerate it locally:

```r
install.packages("renv")
renv::init()
renv::snapshot()
```

For full deployment instructions see the [Posit Connect Cloud R guide](https://docs.posit.co/connect-cloud/how-to/r/dependencies.html).

---

## Data Source

**The Marshall Project — Crime in Context (1975–2015)**
- 68 major US cities
- Four violent crime types: homicide, rape, robbery, aggravated assault
- Rates expressed per 100,000 residents
- Source: FBI Uniform Crime Reporting (UCR) program

[github.com/themarshallproject/city-crime](https://github.com/themarshallproject/city-crime)

---

## Project Structure

```
crime-dashboard-r/
├── app.R          # Main Shiny application
├── renv.lock      # R package dependencies (for Posit Connect deployment)
└── README.md      # This file
```

---

## Related

- Group project (Python Shiny): [DSCI-532_2026_38_crime-dashboard](https://github.com/UBC-MDS/DSCI-532_2026_38_crime-dashboard)
