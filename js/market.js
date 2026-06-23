const stockContainer = document.getElementById("stockContainer");
const searchInput = document.getElementById("searchInput");
const countryFilter = document.getElementById("countryFilter");
const marketFilter = document.getElementById("marketFilter");
const currencySelect = document.getElementById("currencySelect");
const emptyState = document.getElementById("emptyState");
const resultCount = document.getElementById("resultCount");
const apiStatus = document.getElementById("apiStatus");
const apiSearchButton = document.getElementById("apiSearchButton");
const resetButton = document.getElementById("resetButton");
const detectLocationButton = document.getElementById("detectLocationButton");
const marketDateTime = document.getElementById("marketDateTime");

const WATCHLIST_KEY = "stockscope_watchlist_ids";
const DEFAULT_WATCHLIST = [1, 5, 8];
let currentStocks = [...stocks];

function updateMarketDateTime() {
  if (!marketDateTime) return;

  const now = new Date();
  marketDateTime.textContent = `Local date and time: ${now.toLocaleString([], {
    weekday: "short",
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit"
  })}`;
}

function getWatchlistIds() {
  const saved = localStorage.getItem(WATCHLIST_KEY);
  if (saved === null) return [...DEFAULT_WATCHLIST];

  try {
    const parsed = JSON.parse(saved);
    return Array.isArray(parsed) ? parsed.map(Number).filter(Number.isFinite) : [...DEFAULT_WATCHLIST];
  } catch {
    return [...DEFAULT_WATCHLIST];
  }
}

function saveWatchlistIds(ids) {
  localStorage.setItem(WATCHLIST_KEY, JSON.stringify([...new Set(ids.map(Number))]));
}

function isInWatchlist(stockId) {
  return getWatchlistIds().includes(Number(stockId));
}

function toggleWatchlist(stockId) {
  const id = Number(stockId);
  const current = getWatchlistIds();
  const next = current.includes(id)
    ? current.filter((savedId) => savedId !== id)
    : [...current, id];

  saveWatchlistIds(next);
  renderStocks(currentStocks);
}

function convertPrice(price, sourceCurrency, targetCurrency) {
  const sourceRate = currencyRates[sourceCurrency] || 1;
  const targetRate = currencyRates[targetCurrency] || 1;
  return (price / sourceRate) * targetRate;
}

function formatMoney(price, currency) {
  if (!Number.isFinite(price) || price <= 0) return "Price unavailable";
  return `${currencySymbols[currency]}${price.toFixed(2)}`;
}

function getChangeClass(change) {
  return change >= 0 ? "positive" : "negative";
}

function getChangePrefix(change) {
  return change >= 0 ? "+" : "";
}

function updateMarketStatus(message = "", type = "secondary") {
  if (!apiStatus) return;

  if (!message) {
    apiStatus.className = "alert alert-secondary mt-3 mb-0 d-none";
    apiStatus.textContent = "";
    return;
  }

  apiStatus.className = `alert alert-${type} mt-3 mb-0`;
  apiStatus.textContent = message;
}

function uniqueSorted(values) {
  return [...new Set(values)].sort((a, b) => a.localeCompare(b));
}

function populateFilters() {
  const countries = uniqueSorted(stocks.map((stock) => stock.country));
  const markets = uniqueSorted(stocks.map((stock) => stock.market));

  countries.forEach((country) => {
    const option = document.createElement("option");
    option.value = country;
    option.textContent = country;
    countryFilter.appendChild(option);
  });

  markets.forEach((market) => {
    const option = document.createElement("option");
    option.value = market;
    option.textContent = market;
    marketFilter.appendChild(option);
  });
}

function normalizeQuery(query) {
  return query.trim().toLowerCase();
}

function stockMatchesQuery(stock, query) {
  if (!query) return true;

  const searchableText = [
    stock.companyName,
    stock.ticker,
    stock.country,
    stock.market,
    stock.currency,
    stock.searchTerms || ""
  ].join(" ").toLowerCase();

  return searchableText.includes(query);
}

function getFilteredStocks(baseList = stocks) {
  const query = normalizeQuery(searchInput.value);
  const selectedCountry = countryFilter.value;
  const selectedMarket = marketFilter.value;

  return baseList.filter((stock) => {
    const matchesSearch = stockMatchesQuery(stock, query);
    const matchesCountry = selectedCountry === "all" || stock.country === selectedCountry;
    const matchesMarket = selectedMarket === "all" || stock.market === selectedMarket;

    return matchesSearch && matchesCountry && matchesMarket;
  });
}

function renderStocks(stockList) {
  stockContainer.innerHTML = "";
  const selectedCurrency = currencySelect.value;

  resultCount.textContent = `${stockList.length} result${stockList.length === 1 ? "" : "s"}`;

  if (stockList.length === 0) {
    emptyState.style.display = "block";
    return;
  }

  emptyState.style.display = "none";

  stockList.forEach((stock) => {
    const convertedPrice = convertPrice(stock.price, stock.currency, selectedCurrency);
    const changeClass = getChangeClass(stock.change);
    const inWatchlist = isInWatchlist(stock.id);

    const col = document.createElement("div");
    col.className = "col-md-6 col-xl-4";

    col.innerHTML = `
      <article class="stock-card h-100">
        <div class="d-flex justify-content-between align-items-start mb-3">
          <div>
            <h3 class="h5 mb-1">${stock.companyName}</h3>
            <span class="ticker-badge">${stock.ticker}</span>
          </div>
          <span class="${changeClass}" aria-label="${stock.change >= 0 ? "Stock is up" : "Stock is down"}">
            ${stock.change >= 0 ? "▲" : "▼"}
          </span>
        </div>

        <div class="stock-price mb-2">${formatMoney(convertedPrice, selectedCurrency)}</div>

        <p class="mb-2 ${changeClass}">
          ${getChangePrefix(stock.change)}${stock.change.toFixed(2)}
          (${getChangePrefix(stock.changePercent)}${stock.changePercent.toFixed(2)}%)
        </p>

        <p class="stock-meta mb-4">
          ${stock.market} · ${stock.country} · ${stock.currency}
        </p>

        <div class="d-grid gap-2 mt-auto">
          <a class="btn btn-accent" href="stock-detail.html?id=${stock.id}">View details</a>
          <button class="btn ${inWatchlist ? "btn-outline-light-custom" : "btn-watchlist"} watchlist-toggle" type="button" data-stock-id="${stock.id}">
            ${inWatchlist ? "Remove from watchlist" : "Add to watchlist"}
          </button>
        </div>
      </article>
    `;

    stockContainer.appendChild(col);
  });
}

function filterStocks() {
  currentStocks = getFilteredStocks(stocks);
  renderStocks(currentStocks);
  updateMarketStatus("");
}

async function searchMarketData() {
  const query = searchInput.value.trim();
  const localResults = getFilteredStocks(stocks);

  if (!query && countryFilter.value === "all" && marketFilter.value === "all") {
    updateMarketStatus("Type a company or country, choose a market, or use your location.", "warning");
    searchInput.focus();
    return;
  }

  if (localResults.length === 0) {
    currentStocks = [];
    renderStocks(currentStocks);
    updateMarketStatus(`No results found for “${query || countryFilter.value || marketFilter.value}”.`, "warning");
    return;
  }

  apiSearchButton.disabled = true;
  apiSearchButton.textContent = "Searching...";

  try {
    const resultsWithPrices = await stockApi.enrichStocksWithQuotes(localResults);
    currentStocks = resultsWithPrices.length > 0 ? resultsWithPrices : localResults;
  } catch (error) {
    console.warn("Market data refresh failed:", error.message);
    currentStocks = localResults;
  } finally {
    renderStocks(currentStocks);
    updateMarketStatus(`Showing ${currentStocks.length} result${currentStocks.length === 1 ? "" : "s"}.`, "success");
    apiSearchButton.disabled = false;
    apiSearchButton.textContent = "Search";
  }
}

function detectCountryFromCoordinates(latitude, longitude) {
  const inside = (minLat, maxLat, minLon, maxLon) =>
    latitude >= minLat && latitude <= maxLat && longitude >= minLon && longitude <= maxLon;

  if (inside(47.0, 55.2, 5.5, 15.5)) return "Germany";
  if (inside(45.7, 48.0, 5.8, 10.7)) return "Switzerland";
  if (inside(41.0, 51.5, -5.5, 9.7)) return "France";
  if (inside(49.5, 61.0, -8.7, 2.2)) return "United Kingdom";
  if (inside(24.0, 46.0, 122.0, 146.0)) return "Japan";
  if (inside(41.0, 84.0, -141.0, -52.0)) return "Canada";
  if (inside(-44.0, -10.0, 112.0, 154.0)) return "Australia";
  if (inside(24.0, 49.5, -125.0, -66.0)) return "United States";

  return "Germany";
}

function useDeviceLocation() {
  if (!navigator.geolocation) {
    countryFilter.value = "Germany";
    filterStocks();
    updateMarketStatus("Device location is not available. Showing Germany.", "warning");
    return;
  }

  detectLocationButton.disabled = true;
  detectLocationButton.textContent = "Detecting...";

  navigator.geolocation.getCurrentPosition(
    (position) => {
      const detectedCountry = detectCountryFromCoordinates(
        position.coords.latitude,
        position.coords.longitude
      );

      searchInput.value = "";
      countryFilter.value = detectedCountry;
      marketFilter.value = "all";
      currentStocks = getFilteredStocks(stocks);
      renderStocks(currentStocks);
      updateMarketStatus(`Showing market data for ${detectedCountry}.`, "success");
      detectLocationButton.disabled = false;
      detectLocationButton.textContent = "Use my location";
    },
    () => {
      searchInput.value = "";
      countryFilter.value = "Germany";
      marketFilter.value = "all";
      currentStocks = getFilteredStocks(stocks);
      renderStocks(currentStocks);
      updateMarketStatus("Location permission was not enabled. Showing Germany.", "warning");
      detectLocationButton.disabled = false;
      detectLocationButton.textContent = "Use my location";
    },
    { enableHighAccuracy: true, timeout: 8000, maximumAge: 300000 }
  );
}

apiSearchButton.addEventListener("click", searchMarketData);
resetButton.addEventListener("click", () => {
  searchInput.value = "";
  countryFilter.value = "all";
  marketFilter.value = "all";
  currencySelect.value = "USD";
  currentStocks = [...stocks];
  renderStocks(currentStocks);
  updateMarketStatus("");
});

detectLocationButton.addEventListener("click", useDeviceLocation);
searchInput.addEventListener("input", filterStocks);
countryFilter.addEventListener("change", filterStocks);
marketFilter.addEventListener("change", filterStocks);
currencySelect.addEventListener("change", () => renderStocks(currentStocks));

stockContainer.addEventListener("click", (event) => {
  const button = event.target.closest(".watchlist-toggle");
  if (!button) return;
  toggleWatchlist(button.dataset.stockId);
});

populateFilters();
updateMarketDateTime();
setInterval(updateMarketDateTime, 60000);
renderStocks(currentStocks);
