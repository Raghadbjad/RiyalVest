# RiyalVest

RiyalVest is an iOS stock-market learning app that lets users practise portfolio decisions with virtual money. It was built with SwiftUI and is published on the Apple App Store.

<p align="center">
  <img src="https://github.com/user-attachments/assets/fdd38ba1-95af-454f-b91d-8c302dd5cda6" width="250" />
  <img src="https://github.com/user-attachments/assets/dc8d9895-e279-46f7-b263-553048ddc3ea" width="250" />
  <img src="https://github.com/user-attachments/assets/b88b6d06-1de1-4210-bc71-7b2e07eccfe2" width="250" />
</p>

## Product features

- **Virtual trading:** practise buying and selling shares without using real money.
- **Portfolio tracking:** track owned shares and update a virtual cash balance after trades.
- **Market browsing:** view selected stock symbols, company names, prices and price changes.
- **Stock charts:** display an embedded TradingView mini chart for a selected symbol.
- **Market-data integration:** retrieve stock time-series data and company names from Twelve Data.
- **Widget data sharing:** share selected stock data through an App Group using `UserDefaults` and request WidgetKit timeline refreshes.

## Market-data status

The published app is available on the App Store, and the project owner confirms that its market-data/API functionality is currently working.

This GitHub repository contains a Twelve Data integration implemented with `URLSession`, asynchronous Swift calls and `Codable` response models. The exact source-to-binary parity between this repository snapshot and the currently published App Store build has not been independently verified.

## Technology

- Swift and SwiftUI
- `URLSession` and Swift concurrency
- `Codable` for API response decoding
- `ObservableObject` and `@Published` for view-model state
- `UserDefaults` and App Groups for local/shared data
- WidgetKit
- WebKit (`WKWebView`) for the embedded TradingView chart

## Architecture and engineering notes

The current implementation uses SwiftUI views with an `ObservableObject` view model, providing an MVVM-style separation between the stock list's presentation and its data-fetching state. The virtual buy/sell flow currently lives in the trade view and persists portfolio values locally.

Potential next improvements identified during code review:

- Extract API communication into a dedicated service.
- Move portfolio and trade calculations out of SwiftUI views into a testable domain layer.
- Replace hardcoded API credentials with a server-side integration; credentials embedded in a distributed client app cannot be treated as secret.
- Add HTTP status validation, structured error/loading states, bounded retry handling and request cancellation.
- Add unit tests for price-change calculations and buy/sell rules.

## Security note

The current repository snapshot contains a Twelve Data credential hardcoded in source code. It should be treated as exposed because the repository is public. The credential value is intentionally not reproduced here. Rotate it with the provider and avoid shipping provider secrets inside the iOS app. This repository documentation change does not modify the running App Store app or its API configuration.

## Disclaimer

RiyalVest is an educational simulation, not a brokerage service or financial-advice product. Trades use virtual money and do not execute in a real market.

## Running the project

Open the Xcode project/workspace in Xcode and select the RiyalVest app scheme. Before running a local build, configure market-data access through a secure architecture rather than relying on the credential currently present in the repository source.
