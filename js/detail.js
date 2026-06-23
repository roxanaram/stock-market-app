const detailContainer = document.getElementById("detailContainer");
const notFoundMessage = document.getElementById("notFoundMessage");
const rangeButtons = document.querySelectorAll(".time-range-btn");
const currencySelect = document.getElementById("currencySelect");
const apiStatus = document.getElementById("apiStatus");
const refreshDetailButton = document.getElementById("refreshDetailButton");

const WATCHLIST_KEY = "stockscope_watchlist_ids";
const DEFAULT_WATCHLIST = [1, 5, 8];

let selectedStock = null;
let stockChart = null;
let activeRange = "1M";

function getStockIdFromUrl() {
  const params = new URLSearchParams(window.location.search);
  return Number(params.get("id"));
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
  renderDetail();
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

function setApiStatus(message = "", type = "info") {
  if (!apiStatus) return;

  if (!message) {
    apiStatus.className = "d-none";
    apiStatus.textContent = "";
    return;
  }

  const classByType = {
    info: "api-status api-status-info",
    success: "api-status api-status-success",
    warning: "api-status api-status-warning",
    error: "api-status api-status-error"
  };

  apiStatus.className = classByType[type] || classByType.info;
  apiStatus.textContent = message;
}

function getCompanyNewsLinks(stock) {
  const query = encodeURIComponent(`${stock.companyName} ${stock.ticker} stock news`);
  const ticker = encodeURIComponent(stock.ticker);

  return `
    <div class="mt-4">
      <h2 class="h5">Related News</h2>
      <div class="d-grid gap-2">
        <a class="btn btn-outline-light-custom btn-sm" href="https://news.google.com/search?q=${query}" target="_blank" rel="noopener">Company news</a>
        <a class="btn btn-outline-light-custom btn-sm" href="https://finance.yahoo.com/quote/${ticker}" target="_blank" rel="noopener">Market profile</a>
      </div>
    </div>
  `;
}

function renderKeyStatsTable(stock, selectedCurrency) {
  const convertedPrice = convertPrice(stock.price, stock.currency, selectedCurrency);
  const yearStart = stock.history["1Y"]?.[0] || stock.price;
  const convertedYearStart = convertPrice(yearStart, stock.currency, selectedCurrency);
  const yearChange = convertedPrice - convertedYearStart;
  const yearChangePercent = convertedYearStart > 0 ? (yearChange / convertedYearStart) * 100 : 0;
  const dayLow = Math.min(...stock.history["1D"]);
  const dayHigh = Math.max(...stock.history["1D"]);

  const rows = [
    ["Ticker", stock.ticker],
    ["Market", stock.market],
    ["Country", stock.country],
    ["Currency", selectedCurrency],
    ["Current price", formatMoney(convertedPrice, selectedCurrency)],
    ["Day range", `${formatMoney(convertPrice(dayLow, stock.currency, selectedCurrency), selectedCurrency)} - ${formatMoney(convertPrice(dayHigh, stock.currency, selectedCurrency), selectedCurrency)}`],
    ["1Y movement", `<span class="${getChangeClass(yearChange)}">${getChangePrefix(yearChange)}${yearChange.toFixed(2)} (${getChangePrefix(yearChangePercent)}${yearChangePercent.toFixed(2)}%)</span>`]
  ];

  return `
    <div class="key-info-card">
      <h2 class="h5 mb-3">Key Information</h2>
      <div class="key-info-grid">
        ${rows.map(([label, value]) => `
          <div class="key-info-row">
            <div class="key-info-label">${label}</div>
            <div class="key-info-value">${value}</div>
          </div>
        `).join("")}
      </div>
    </div>
  `;
}

function renderDetail() {
  const selectedCurrency = currencySelect.value;
  const convertedPrice = convertPrice(selectedStock.price, selectedStock.currency, selectedCurrency);
  const changeClass = getChangeClass(selectedStock.change);
  const inWatchlist = isInWatchlist(selectedStock.id);

  detailContainer.innerHTML = `
    <div class="row g-4">
      <div class="col-lg-5">
        <div class="detail-panel h-100">
          <div class="d-flex flex-wrap gap-2 mb-3">
            <span class="ticker-badge">${selectedStock.ticker}</span>
          </div>

          <h1 class="display-6 fw-bold">${selectedStock.companyName}</h1>
          <p class="text-muted-custom">${selectedStock.description}</p>

          <div class="stock-price mt-4">${formatMoney(convertedPrice, selectedCurrency)}</div>
          <p class="${changeClass}">
            ${getChangePrefix(selectedStock.change)}${selectedStock.change.toFixed(2)}
            (${getChangePrefix(selectedStock.changePercent)}${selectedStock.changePercent.toFixed(2)}%)
          </p>

          <div class="d-grid gap-2 mt-4">
            <button id="detailWatchlistButton" class="btn ${inWatchlist ? "btn-outline-light-custom" : "btn-watchlist"}" type="button">
              ${inWatchlist ? "Remove from watchlist" : "Add to watchlist"}
            </button>
            <a href="market.html" class="btn btn-outline-light-custom">Back to market</a>
          </div>

          ${renderKeyStatsTable(selectedStock, selectedCurrency)}
          ${getCompanyNewsLinks(selectedStock)}
        </div>
      </div>

      <div class="col-lg-7">
        <div class="detail-panel h-100">
          <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <div>
              <h2 class="h4 mb-1">Price History</h2>
              <p class="text-muted-custom mb-0">Interactive price chart for 1 day, 1 month, 3 months, or 1 year.</p>
            </div>
          </div>
          <div class="chart-box">
            <canvas id="dynamicStockChart"></canvas>
          </div>
        </div>
      </div>
    </div>
  `;

  document.getElementById("detailWatchlistButton").addEventListener("click", () => toggleWatchlist(selectedStock.id));
  renderChart();
}

function getChartLabels() {
  if (selectedStock.historyLabels && selectedStock.historyLabels[activeRange]) {
    return selectedStock.historyLabels[activeRange];
  }

  return {
    "1D": ["Open", "Late Morning", "Midday", "Afternoon", "Close"],
    "1M": ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Now"],
    "3M": ["Month 1", "Month 1.5", "Month 2", "Month 2.5", "Month 3", "Now"],
    "1Y": ["Q1", "Q2", "Q3", "Q4", "Recent", "Now"]
  }[activeRange];
}

function renderChart() {
  const selectedCurrency = currencySelect.value;
  const chartElement = document.getElementById("dynamicStockChart");
  const history = selectedStock.history[activeRange].map((price) =>
    convertPrice(price, selectedStock.currency, selectedCurrency)
  );

  if (stockChart) {
    stockChart.destroy();
  }

  stockChart = new Chart(chartElement, {
    type: "line",
    data: {
      labels: getChartLabels(),
      datasets: [
        {
          label: `${selectedStock.ticker} price (${selectedCurrency})`,
          data: history,
          tension: 0.35,
          fill: true
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          labels: { color: "#f8fafc" }
        }
      },
      scales: {
        x: {
          ticks: { color: "#aab6c8", maxRotation: 35, minRotation: 0 },
          grid: { color: "rgba(255,255,255,0.08)" }
        },
        y: {
          ticks: { color: "#aab6c8" },
          grid: { color: "rgba(255,255,255,0.08)" }
        }
      }
    }
  });
}

async function loadDetailApiData() {
  if (!selectedStock || !refreshDetailButton) return;

  refreshDetailButton.disabled = true;
  refreshDetailButton.textContent = "Refreshing...";

  try {
    const result = await stockApi.refreshSingleStock(selectedStock);
    selectedStock = result;
    renderDetail();
    setApiStatus("Market data refreshed.", "success");
  } catch (error) {
    console.warn("Stock refresh failed:", error.message);
    setApiStatus("Showing latest available market data.", "warning");
  } finally {
    refreshDetailButton.disabled = false;
    refreshDetailButton.textContent = "Refresh data";
  }
}

rangeButtons.forEach((button) => {
  button.addEventListener("click", () => {
    rangeButtons.forEach((btn) => btn.classList.remove("active"));
    button.classList.add("active");
    activeRange = button.dataset.range;
    renderChart();
  });
});

currencySelect.addEventListener("change", renderDetail);
refreshDetailButton.addEventListener("click", loadDetailApiData);

const stockId = getStockIdFromUrl();
selectedStock = stocks.find((stock) => stock.id === stockId);

if (!selectedStock) {
  detailContainer.style.display = "none";
  notFoundMessage.style.display = "block";
  setApiStatus("No stock was found for this page.", "error");
} else {
  notFoundMessage.style.display = "none";
  renderDetail();
}
