
# Crime Dashboard - Individual Assignment
# R Shiny reimplementation of the group Python Shiny project
# Data: Marshall Project UCR Crime Data (1975-2015), 68 US cities


library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(DT)

# -----------------------------------------------------------------------------
# Load data directly from the Marshall Project GitHub
# -----------------------------------------------------------------------------
DATA_URL <- paste0(
  "https://raw.githubusercontent.com/themarshallproject/",
  "city-crime/master/data/ucr_crime_1975_2015.csv"
)

crime_raw <- read.csv(DATA_URL, stringsAsFactors = FALSE)


crime <- crime_raw |>
  select(
    city          = department_name,
    year,
    population    = total_pop,
    homicide      = homs_per_100k,
    rape          = rape_per_100k,
    robbery       = rob_per_100k,
    assault       = agg_ass_per_100k,
    violent_total = violent_per_100k
  ) |>
  filter(!is.na(violent_total))

# Sorted unique city names for the dropdown
all_cities <- sort(unique(crime$city))

# Default cities to show so the app isn't empty on load
default_cities <- c("New York", "Los Angeles", "Chicago", "Houston", "Phoenix")
default_cities <- intersect(default_cities, all_cities)


ui <- page_sidebar(
  title = "US City Crime Dashboard (1975–2015)",
  theme = bs_theme(bootswatch = "flatly", base_font = font_google("Inter")),

  # ---- Sidebar controls ----
  sidebar = sidebar(
    width = 280,

    # 1) Crime type selector  [INPUT #1 - required]
    selectInput(
      inputId  = "crime_type",
      label    = "Crime type (per 100k residents)",
      choices  = c(
        "Total violent crime" = "violent_total",
        "Homicide"            = "homicide",
        "Rape"                = "rape",
        "Robbery"             = "robbery",
        "Assault"             = "assault"
      ),
      selected = "violent_total"
    ),

    # 2) Year range slider  [INPUT #2 - bonus]
    sliderInput(
      inputId = "year_range",
      label   = "Year range",
      min     = 1975,
      max     = 2015,
      value   = c(1975, 2015),
      sep     = "",
      step    = 1
    ),

    # 3) City selector  [INPUT #3 - bonus]
    selectizeInput(
      inputId  = "cities",
      label    = "Cities to highlight (trend chart)",
      choices  = all_cities,
      selected = default_cities,
      multiple = TRUE,
      options  = list(maxItems = 10, placeholder = "Select up to 10 cities")
    ),

    hr(),
    p(
      "Data: ",
      a("The Marshall Project", href = "https://github.com/themarshallproject/city-crime",
        target = "_blank"),
      style = "font-size: 0.8rem; color: #888;"
    )
  ),

  # ---- Main panel ----
  layout_columns(
    col_widths = c(4, 4, 4),

    # Value boxes row  [OUTPUT #1, #2, #3 - required]
    value_box(
      title    = "Cities tracked",
      value    = textOutput("vb_cities"),
      showcase = bsicons::bs_icon("buildings"),
      theme    = "primary"
    ),
    value_box(
      title    = "Years in range",
      value    = textOutput("vb_years"),
      showcase = bsicons::bs_icon("calendar-range"),
      theme    = "info"
    ),
    value_box(
      title    = "National avg (selected metric)",
      value    = textOutput("vb_avg"),
      showcase = bsicons::bs_icon("bar-chart-line"),
      theme    = "success"
    )
  ),

  layout_columns(
    col_widths = c(7, 5),

    # Trend line chart  [OUTPUT #4]
    card(
      card_header("Crime Rate Trend Over Time"),
      plotOutput("trend_plot", height = "380px")
    ),

    # Top cities bar chart  [OUTPUT #5]
    card(
      card_header("Average Rate by City (top 15)"),
      plotOutput("bar_plot", height = "380px")
    )
  ),

  # Data table  [OUTPUT #6]
  card(
    card_header("Filtered Data Table"),
    DTOutput("data_table")
  )
)


# Server

server <- function(input, output, session) {


  # REACTIVE CALC — filtered dataframe  [required reactive calc]

  filtered_data <- reactive({
    crime |>
      filter(
        year >= input$year_range[1],
        year <= input$year_range[2]
      )
  })

  # Subset further to just the selected cities (for trend chart)
  city_data <- reactive({
    filtered_data() |>
      filter(city %in% input$cities)
  })

  # Helper: pull the right column by name
  metric_col <- reactive({ input$crime_type })


  # VALUE BOXES
  
  output$vb_cities <- renderText({
    n_distinct(filtered_data()$city)
  })

  output$vb_years <- renderText({
    diff(input$year_range) + 1
  })

  output$vb_avg <- renderText({
    col <- metric_col()
    val <- mean(filtered_data()[[col]], na.rm = TRUE)
    paste0(round(val, 1), " per 100k")
  })

  
  # TREND CHART — OUTPUT #1 (main chart)

  output$trend_plot <- renderPlot({
    req(nrow(city_data()) > 0)

    col   <- metric_col()
    label <- names(which(
      c("violent_total","homicide","rape","robbery","assault") == col
    ))

    city_data() |>
      rename(metric = all_of(col)) |>
      filter(!is.na(metric)) |>
      ggplot(aes(x = year, y = metric, colour = city)) +
      geom_line(linewidth = 0.9, alpha = 0.85) +
      geom_point(size = 1.4, alpha = 0.7) +
      scale_colour_viridis_d(option = "turbo") +
      labs(
        x      = "Year",
        y      = paste(tools::toTitleCase(gsub("_", " ", col)), "(per 100k)"),
        colour = "City"
      ) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom",
            legend.text = element_text(size = 8))
  })


  # BAR CHART — OUTPUT #2 (second required output)
 
  output$bar_plot <- renderPlot({
    col <- metric_col()

    filtered_data() |>
      rename(metric = all_of(col)) |>
      group_by(city) |>
      summarise(avg = mean(metric, na.rm = TRUE), .groups = "drop") |>
      slice_max(avg, n = 15) |>
      mutate(city = reorder(city, avg)) |>
      ggplot(aes(x = avg, y = city, fill = avg)) +
      geom_col(show.legend = FALSE) +
      scale_fill_viridis_c(option = "magma", direction = -1) +
      labs(
        x = paste(tools::toTitleCase(gsub("_", " ", col)), "(avg per 100k)"),
        y = NULL
      ) +
      theme_minimal(base_size = 12)
  })


  # DATA TABLE — OUTPUT #3
 
  output$data_table <- renderDT({
    col <- metric_col()

    filtered_data() |>
      rename(metric = all_of(col)) |>
      select(City = city, Year = year, Population = population,
             Rate = metric) |>
      arrange(desc(Year), desc(Rate)) |>
      datatable(
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      ) |>
      formatRound("Rate", digits = 1) |>
      formatCurrency("Population", currency = "", interval = 3,
                     mark = ",", digits = 0)
  })
}


# Run
# -----------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
