import Foundation
import Combine
import WidgetKit

@MainActor
final class StockViewModel: ObservableObject {
    @Published private(set) var stocks: [Stock] = []
    @Published private(set) var lastFetchedStocks: [Stock] = []

    private let symbols = ["AAPL", "MSFT", "GOOGL", "TSLA", "META"]
    private let apiKey = "ecf6db49df374c2b97930d9569bae2ae"
    private let refreshInterval: TimeInterval = 300

    private var timer: Timer?
    private var isFetching = false
    private var stockNamesCache: [String: String] = [:]

    init() {
        startTimer()
    }

    func startTimer() {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.fetchStocks()
            }
        }
    }

    func fetchStocks() async {
        // Prevent the timer and the initial screen load from starting overlapping batches.
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }

        for symbol in symbols {
            guard !Task.isCancelled else { return }

            do {
                let data = try await requestData(endpoint: "time_series", symbol: symbol)
                let response = try JSONDecoder().decode(StockResponse.self, from: data)

                if response.code == 429 {
                    // Keep the last successful values. Do not recursively retry and create
                    // an unbounded number of API requests.
                    stocks = lastFetchedStocks
                    print("Twelve Data rate limit reached. Keeping the last successful values.")
                    return
                }

                guard response.status == "ok" else {
                    print("Twelve Data returned an unsuccessful response for \(symbol): \(response.message ?? "Unknown API error").")
                    continue
                }

                let name = await fetchStockName(for: symbol)
                guard let stock = response.toStock(name: name) else {
                    print("Could not decode usable price data for \(symbol).")
                    continue
                }

                if let index = stocks.firstIndex(where: { $0.symbol == stock.symbol }) {
                    stocks[index] = stock
                } else {
                    stocks.append(stock)
                }

                lastFetchedStocks = stocks
            } catch {
                print("Failed to fetch \(symbol): \(error.localizedDescription)")
            }
        }

        saveTopStocks(Array(stocks.prefix(3)))
    }

    private func requestData(endpoint: String, symbol: String) async throws -> Data {
        guard var components = URLComponents(string: "https://api.twelvedata.com/\(endpoint)") else {
            throw StockAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "country", value: "United States")
        ]

        if endpoint == "time_series" {
            components.queryItems?.append(URLQueryItem(name: "interval", value: "5min"))
        }

        guard let url = components.url else {
            throw StockAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw StockAPIError.invalidHTTPResponse
        }

        return data
    }

    private func fetchStockName(for symbol: String) async -> String {
        if let cachedName = stockNamesCache[symbol] {
            return cachedName
        }

        do {
            let data = try await requestData(endpoint: "stocks", symbol: symbol)
            let response = try JSONDecoder().decode(StockNameResponse.self, from: data)

            guard let name = response.data.first?.name, !name.isEmpty else {
                return symbol
            }

            stockNamesCache[symbol] = name
            return name
        } catch {
            print("Failed to fetch company name for \(symbol): \(error.localizedDescription)")
            return symbol
        }
    }

    private func saveTopStocks(_ stocks: [Stock]) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.raghad.RiyalVest"),
              let encodedData = try? JSONEncoder().encode(stocks) else {
            print("Unable to save top stocks to the shared App Group.")
            return
        }

        sharedDefaults.set(encodedData, forKey: "topStocks")
        WidgetCenter.shared.reloadAllTimelines()
    }
}

private enum StockAPIError: LocalizedError {
    case invalidURL
    case invalidHTTPResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The stock API URL could not be created."
        case .invalidHTTPResponse:
            return "The stock API returned an invalid HTTP response."
        }
    }
}

struct StockResponse: Codable {
    let code: Int?
    let message: String?
    let status: String?
    let meta: Meta?
    let values: [Value]?

    func toStock(name: String) -> Stock? {
        guard status == "ok",
              let meta,
              let values,
              let latestValue = values.first,
              let latestPrice = Double(latestValue.close) else {
            return nil
        }

        let previousValue = values.count > 1 ? values[1] : latestValue
        guard let previousPrice = Double(previousValue.close) else {
            return nil
        }

        let change = latestPrice - previousPrice
        let changePercent = previousPrice == 0 ? 0 : (change / previousPrice) * 100

        return Stock(
            symbol: meta.symbol,
            price: String(format: "%.2f", latestPrice),
            change: String(format: "%.2f", change),
            changePercent: String(format: "%.2f%%", changePercent),
            name: name
        )
    }
}

struct StockNameResponse: Codable {
    let status: String
    let data: [StockData]
}

struct StockData: Codable {
    let symbol: String
    let name: String
}

struct Meta: Codable {
    let symbol: String
}

struct Value: Codable {
    let datetime: String
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
}
