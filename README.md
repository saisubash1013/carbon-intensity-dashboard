# Carbon Intensity Dashboard

A Flutter application that displays UK carbon intensity data with current value, historical trend, and daily statistics using the official Carbon Intensity API.

## Features

  - View current carbon intensity with index and last updated time

  - Half-hourly chart showing Actual vs Forecast values

  - Daily statistics: Minimum, Maximum, and Average intensity

  - Pull-to-refresh and manual refresh support

  - Network error handling with retry option

  - Responsive layout for different screen sizes

  - Clean architecture with separated API, models, controller, and UI

## API Used

UK National Grid Carbon Intensity API
https://api.carbonintensity.org.uk/

Endpoints used:
  - /intensity
  - /intensity/date/{date}

## How to Run
flutter pub get
flutter run

Author
# *Subash G*
