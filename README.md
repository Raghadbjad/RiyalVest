# RiyalVest

RiyalVest is an iOS stock-market learning app that lets users practise portfolio decisions with virtual money. It was built with SwiftUI as a learning project focused on presenting market information and simulating basic buy/sell flows.

<p align="center">
  <img src="https://github.com/user-attachments/assets/fdd38ba1-95af-454f-b91d-8c302dd5cda6" width="250" />
  <img src="https://github.com/user-attachments/assets/dc8d9895-e279-46f7-b263-553048ddc3ea" width="250" />
  <img src="https://github.com/user-attachments/assets/b88b6d06-1de1-4210-bc71-7b2e07eccfe2" width="250" />
</p>

## What the app demonstrates

- **Virtual trading:** practise buying and selling shares without using real money.
- **Portfolio state:** track owned shares and update a virtual cash balance after trades.
- **Stock browsing:** view a selected list of stock symbols, names, prices and price changes.
- **Stock charts:** display an embedded TradingView mini chart for a selected symbol.
- **Market-data integration:** the project contains a Twelve Data API integration using `URLSession`, asynchronous calls and `Codable` response models.
- **Widget data sharing:** the app writes selected stock data to an App Group using `UserDefaults` and requests a WidgetKit timeline refresh.

> **Market-data status:** The source includes a Twelve Data integration, but the API credential previously present in the code may no longer be active. Live data availability has not been verified. Do not treat the displayed data as guaranteed real-time market data. A valid credential and a safer configuration are required to run the live-data flow.

## Built with

- Swift
- SwiftUI
- URLSession and async/await
- Codable
- UserDefaults and App Groups
- WidgetKit
- WebKit (`WKWebView`) for the embedded chart

## Engineering notes

The current codebase uses SwiftUI views with an `ObservableObject` view model (an MVVM-style separation), plus local persistence for the virtual portfolio. The next engineering improvements are to move network access into a dedicated service, keep credentials out of source control, centralise portfolio/trade logic, improve error and loading states, and add meaningful unit tests.

## Important

RiyalVest is an educational simulation, not a brokerage service or financial-advice product. Trades use virtual money and do not execute in a real market.

## Running the project

Open the Xcode project/workspace in Xcode and select the RiyalVest app scheme. The live market-data functionality requires a valid Twelve Data credential configured outside the committed source code. Until that configuration is added and verified, live market data should be considered unavailable.

---

