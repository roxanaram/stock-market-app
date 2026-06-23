const WATCHLIST_KEY = "stockscope_watchlist_ids";
const DEFAULT_WATCHLIST = [1, 5, 8];

const portfolioContainer = document.getElementById("portfolioContainer");
const portfolioEmptyState = document.getElementById("portfolioEmptyState");
const portfolioCount = document.getElementById("portfolioCount");
const portfolioTotalValue = document.getElementById("portfolioTotalValue");
const portfolioTotalChange = document.getElementById("portfolioTotalChange");
const portfolioBestMover = document.getElementById("portfolioBestMover");
const portfolioCurrency = document.getElementById("portfolioCurrency");
const portfolioUserMessage = document.getElementById("portfolioUserMessage");

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

function getWatchlistStocks() {
  const ids = getWatchlistIds();
  return ids
    .map((id) => stocks.find((stock) => stock.id === id))
    .filter(Boolean);
}

function removeFromWatchlist(stockId) {
  const id = Number(stockId);
  const next = getWatchlistIds().filter((savedId) => savedId !== id);
  saveWatchlistIds(next);
  renderPortfolio();
}

function renderSummary(watchlistStocks) {
  const selectedCurrency = portfolioCurrency.value;
  const total = watchlistStocks.reduce((sum, stock) => {
    return sum + convertPrice(stock.price, stock.currency, selectedCurrency);
  }, 0);

  const averageChange = watchlistStocks.length
    ? watchlistStocks.reduce((sum, stock) => sum + stock.changePercent, 0) / watchlistStocks.length
    : 0;

  const best = watchlistStocks.length
    ? [...watchlistStocks].sort((a, b) => b.changePercent - a.changePercent)[0]
    : null;

  portfolioCount.textContent = `${watchlistStocks.length}`;
  portfolioTotalValue.textContent = formatMoney(total, selectedCurrency);
  portfolioTotalChange.textContent = `${getChangePrefix(averageChange)}${averageChange.toFixed(2)}%`;
  portfolioTotalChange.className = getChangeClass(averageChange);
  portfolioBestMover.textContent = best ? `${best.ticker} ${getChangePrefix(best.changePercent)}${best.changePercent.toFixed(2)}%` : "No stocks";
  portfolioBestMover.className = best ? getChangeClass(best.changePercent) : "text-muted-custom";
}

function renderPortfolio() {
  const watchlistStocks = getWatchlistStocks();
  const selectedCurrency = portfolioCurrency.value;

  renderSummary(watchlistStocks);
  portfolioContainer.innerHTML = "";

  if (watchlistStocks.length === 0) {
    portfolioEmptyState.style.display = "block";
    return;
  }

  portfolioEmptyState.style.display = "none";

  watchlistStocks.forEach((stock) => {
    const convertedPrice = convertPrice(stock.price, stock.currency, selectedCurrency);
    const changeClass = getChangeClass(stock.change);
    const col = document.createElement("div");
    col.className = "col-md-6 col-xl-4";

    col.innerHTML = `
      <article class="app-card h-100">
        <div class="d-flex justify-content-between align-items-start gap-3 mb-3">
          <div>
            <h2 class="h5 mb-1">${stock.companyName}</h2>
            <p class="text-muted-custom mb-0">${stock.ticker} · ${stock.market} · ${stock.country}</p>
          </div>
          <span class="${changeClass}">${stock.change >= 0 ? "▲" : "▼"}</span>
        </div>

        <p class="stock-price mb-2">${formatMoney(convertedPrice, selectedCurrency)}</p>
        <p class="${changeClass}">
          ${getChangePrefix(stock.change)}${stock.change.toFixed(2)}
          (${getChangePrefix(stock.changePercent)}${stock.changePercent.toFixed(2)}%)
        </p>

        <div class="d-grid gap-2 mt-4">
          <a href="stock-detail.html?id=${stock.id}" class="btn btn-accent">View details</a>
          <button class="btn btn-outline-light-custom remove-watchlist" type="button" data-stock-id="${stock.id}">Remove</button>
        </div>
      </article>
    `;

    portfolioContainer.appendChild(col);
  });
}

portfolioContainer.addEventListener("click", (event) => {
  const button = event.target.closest(".remove-watchlist");
  if (!button) return;
  removeFromWatchlist(button.dataset.stockId);
});

portfolioCurrency.addEventListener("change", renderPortfolio);

if (typeof getCurrentUser === "function") {
  const currentUser = getCurrentUser();
  if (currentUser) {
    portfolioUserMessage.textContent = `Welcome, ${currentUser.name}. This is your watchlist.`;
  }
}

renderPortfolio();
