# StockScope

A responsive stock market application with a web version and a Flutter mobile app.  
The project allows users to explore stocks, view market data, check company details, manage a watchlist, switch currencies, and use location-based market filtering.

![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![Chart.js](https://img.shields.io/badge/Chart.js-FF6384?style=for-the-badge&logo=chartdotjs&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)

---

## Project Overview

StockScope is a stock market tracking project developed as a frontend-focused application.  
It contains a responsive web application and a Flutter mobile application with a similar product idea and visual style.

The web application is built with HTML, CSS, Bootstrap, Vanilla JavaScript, and Chart.js.  
The mobile application is built with Flutter and Dart.

The application is designed to help users:

- search for stocks by company, ticker, country, or market;
- view stock cards with price movement indicators;
- open a detailed stock page;
- switch between different currencies;
- view different chart ranges;
- add and remove stocks from a watchlist;
- use location-based market filtering;
- access a Pro subscription page;
- register and sign in through a frontend authentication simulation.

---

## Features

### Market Search

Users can search stocks by:

- company name;
- ticker symbol;
- country;
- market.

The market page also includes filters for country, market, and currency.

### Stock Detail Page

Each stock has a detail page with:

- company name and ticker;
- current price;
- daily movement;
- market and country information;
- key information section;
- interactive Chart.js chart;
- range buttons for 1 Day, 1 Month, 3 Months, and 1 Year;
- related external news links;
- add/remove watchlist action.

### Watchlist / Portfolio

Users can add stocks to a watchlist from the market page or the stock detail page.

The portfolio page displays:

- selected watchlist stocks;
- current values;
- movement indicators;
- portfolio summary;
- remove action for each item.

### Currency Switching

The app supports switching between several currencies, including:

- USD;
- EUR;
- GBP;
- JPY;
- CHF.

### Location-Based Market Filtering

The web app includes a location button that uses browser geolocation.  
If location access is allowed, the app suggests a relevant market based on the detected country.  
If location access is denied or unavailable, the app continues working with default market data.

### Login and Registration

The login page is implemented as a frontend authentication simulation.

The registration form validates:

- full name;
- email format;
- password strength;
- password confirmation.

Password rules:

- at least 8 characters;
- at least one uppercase letter;
- at least one lowercase letter;
- at least one number.

Since the project does not use a backend database, registered users are stored in browser storage for the demo.

### Pro Page

The Pro page includes:

- monthly and yearly subscription options;
- selected plan state;
- feature list;
- icons;
- pricing cards;
- design aligned with the mobile app.

---

## Pages

The web application contains the following pages:

| Page | File | Description |
|---|---|---|
| Home | `index.html` | Landing page and project introduction |
| Market | `market.html` | Stock search, filters, currency switcher, and stock cards |
| Stock Detail | `stock-detail.html` | Detailed company page with chart, key information, and news links |
| Portfolio | `portfolio.html` | Watchlist and portfolio summary |
| Pro | `pro.html` | Subscription plan page |
| Login | `login.html` | Registration and sign-in page |

---

## Technologies Used

### Web Application

- HTML5
- CSS3
- Bootstrap 5
- Vanilla JavaScript
- Chart.js
- Browser Geolocation API
- Browser Storage

### Mobile Application

- Flutter
- Dart
- HTTP package
- Geolocator package
- Geocoding package
- fl_chart package
- url_launcher package

---

## Project Structure

```text
stock-market-final/
│
├── index.html
├── market.html
├── stock-detail.html
├── portfolio.html
├── pro.html
├── login.html
├── README.md
│
├── css/
│   └── style.css
│
├── js/
│   ├── app.js
│   ├── auth.js
│   ├── data.js
│   ├── detail.js
│   ├── market.js
│   └── portfolio.js
│
├── assets/
│   ├── icons/
│   └── images/
│
└── mobile-app/
    ├── android/
    ├── ios/
    ├── lib/
    ├── test/
    ├── web/
    ├── pubspec.yaml
    └── README.md
````

---

## How to Run the Web App Locally

1. Open the project folder in VS Code.

2. Install the Live Server extension if it is not installed.

3. Open `index.html`.

4. Right-click and select:

```text
Open with Live Server
```

5. The website will open in the browser.

---

## How to Run the Flutter App

1. Open the mobile app folder:

```text
mobile-app/
```

2. Install Flutter dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

---

## GitHub Pages Deployment

The web app can be deployed through GitHub Pages.

Recommended settings:

```text
Source: Deploy from a branch
Branch: main
Folder: /root
```

After deployment, the website will be available as a public GitHub Pages link.

---

## Notes

This project is frontend-focused.
The login system is a frontend simulation and does not use a backend database.
Stock data is handled with API-based logic and stable fallback data to keep the demo reliable.
The application is designed to remain usable even if external API limits or network issues occur.



```
```
