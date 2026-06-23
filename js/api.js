// Marketstack API integration for the StockScope web app.
// The app uses current market data when available and keeps stable local stock data for reliability.

const stockApi = {
  providerName: "Marketstack",
  apiKey: "cedd6a25525aa1eba28608b29d746b6b",
  baseUrl: "https://api.marketstack.com/v1",

  getApiSymbol(stock) {
    return stock.apiSymbol || stock.ticker;
  },

  normalizeQuote(rawQuote, fallbackSymbol) {
    const price = Number(rawQuote.close || rawQuote.adj_close || rawQuote.price);
    const open = Number(rawQuote.open || price);

    if (!Number.isFinite(price) || price <= 0) {
      throw new Error("Marketstack returned no valid price.");
    }

    const change = Number.isFinite(open) && open > 0 ? price - open : 0;
    const changePercent = Number.isFinite(open) && open > 0 ? (change / open) * 100 : 0;

    return {
      symbol: rawQuote.symbol || fallbackSymbol,
      price,
      change,
      changePercent,
      latestTradingDay: rawQuote.date ? String(rawQuote.date).slice(0, 10) : "",
      exchange: rawQuote.exchange || "",
      source: "Marketstack EOD Latest"
    };
  },

  async fetchQuotes(symbols) {
    if (!this.apiKey || this.apiKey.includes("PASTE_MARKETSTACK_KEY_HERE")) {
      throw new Error("Missing Marketstack API key.");
    }

    const cleanSymbols = symbols
      .filter(Boolean)
      .map((symbol) => String(symbol).trim())
      .filter((symbol) => symbol.length > 0)
      .slice(0, 5);

    if (cleanSymbols.length === 0) {
      return [];
    }

    const joinedSymbols = cleanSymbols.map(encodeURIComponent).join(",");
    const url = `${this.baseUrl}/eod/latest?access_key=${this.apiKey}&symbols=${joinedSymbols}`;

    const response = await fetch(url);

    if (!response.ok) {
      throw new Error("Marketstack request failed.");
    }

    const data = await response.json();

    if (data.error) {
      throw new Error(data.error.message || data.error.info || "Marketstack API error.");
    }

    if (!Array.isArray(data.data) || data.data.length === 0) {
      throw new Error("No Marketstack data found for these symbols.");
    }

    return data.data.map((quote) => this.normalizeQuote(quote, quote.symbol));
  },

  async fetchQuote(symbol) {
    const quotes = await this.fetchQuotes([symbol]);

    if (!quotes.length) {
      throw new Error("No quote data found for this symbol.");
    }

    return quotes[0];
  },

  async searchSymbols(query) {
    const q = query.trim().toLowerCase();

    if (!q) {
      return [];
    }

    // Marketstack search can be limited, so we search our local catalog first.
    // Then we enrich matching stocks with real Marketstack prices.
    return stocks
      .filter((stock) => {
        return (
          stock.companyName.toLowerCase().includes(q) ||
          stock.ticker.toLowerCase().includes(q) ||
          stock.country.toLowerCase().includes(q) ||
          stock.market.toLowerCase().includes(q)
        );
      })
      .slice(0, 8)
      .map((stock) => ({
        ...stock,
        apiSource: "Local catalog match",
        dataSource: "Local catalog match",
        apiUpdated: false
      }));
  },

  async enrichStocksWithQuotes(stockList) {
    try {
      const symbols = stockList.map((stock) => this.getApiSymbol(stock));
      const quotes = await this.fetchQuotes(symbols);

      const quoteBySymbol = new Map();

      quotes.forEach((quote) => {
        quoteBySymbol.set(String(quote.symbol).toUpperCase(), quote);
      });

      return stockList.map((stock) => {
        const apiSymbol = this.getApiSymbol(stock);
        const quote = quoteBySymbol.get(String(apiSymbol).toUpperCase());

        if (!quote) {
          return {
            ...stock,
            apiSource: "Market data",
            dataSource: "Market data",
            apiUpdated: false
          };
        }

        return {
          ...stock,
          price: quote.price,
          change: quote.change,
          changePercent: quote.changePercent,
          market: quote.exchange || stock.market,
          latestTradingDay: quote.latestTradingDay,
          apiSource: quote.source,
          dataSource: quote.source,
          apiUpdated: true
        };
      });
    } catch (error) {
      console.warn("Marketstack enrich failed:", error.message);
      return [];
    }
  },

  async refreshSingleStock(stock) {
    try {
      const quote = await this.fetchQuote(this.getApiSymbol(stock));

      return {
        ...stock,
        price: quote.price,
        change: quote.change,
        changePercent: quote.changePercent,
        market: quote.exchange || stock.market,
        latestTradingDay: quote.latestTradingDay,
        apiSource: quote.source,
        dataSource: quote.source,
        apiUpdated: true
      };
    } catch (error) {
      console.warn(`Local market data used for ${stock.ticker}:`, error.message);

      return {
        ...stock,
        apiSource: "Market data",
        dataSource: "Market data",
        apiUpdated: false
      };
    }
  }
};