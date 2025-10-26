# TrustSeal - The Verification Layer for BlockDAG

A Flutter web application that provides a comprehensive trust and verification system for the BlockDAG ecosystem.

## Features

### ✅ Completed Features

- **Project Verification System**
  - Three-tier verification status (Verified, Under Review, Unverified)
  - Visual verification badges with color coding
  - Detailed verification status cards

- **Project Management**
  - Comprehensive project listings with search and filtering
  - Detailed project pages with metrics and audit information
  - Tokenomics visualization and distribution charts

- **Modern UI/UX**
  - Responsive design optimized for web
  - Material Design 3 components
  - Google Fonts integration
  - Professional color scheme and typography

- **Data Management**
  - Mock data service with realistic project information
  - Real-time analytics dashboard
  - Project metrics and trust scoring

### 🚧 In Progress

- **Wallet Integration**
  - Web3 wallet connection
  - Real-time verification status checks
  - Portfolio tracking

- **Content Creator Features**
  - Analytics dashboard for content creators
  - Performance tracking and rewards
  - Twitter API integration

## Project Structure

```
lib/
├── constants/
│   └── app_constants.dart          # App-wide constants and styling
├── models/
│   └── project.dart                # Data models for projects and verification
├── screens/
│   ├── home_screen.dart            # Main dashboard with project listings
│   └── project_detail_screen.dart  # Detailed project view
├── services/
│   └── project_service.dart        # Mock data service and API calls
├── widgets/
│   ├── project_card.dart           # Project listing cards
│   └── verification_badge.dart    # Verification status components
└── main.dart                      # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (3.35.5 or later)
- Dart SDK (3.9.2 or later)
- Web browser for testing

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd trustseal_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the web app:
```bash
flutter run -d web-server --web-port 8080
```

4. Open your browser and navigate to `http://localhost:8080`

## Key Components

### Verification System

The app implements a comprehensive verification system with three tiers:

- **🟢 Verified**: Full trust, passed all audits, liquidity locked 6+ months
- **🟡 Under Review**: Initial application approved, 30-day monitoring period  
- **🔴 Unverified**: Failed audit requirements, high risk indicators

### Project Cards

Each project is displayed with:
- Project logo and basic information
- Verification status badge
- Trust score (0-10 scale)
- Key metrics (market cap, liquidity, holders)
- Social media links

### Analytics Dashboard

The home screen includes:
- Total project count
- Verification status breakdown
- Average trust score across all projects
- Real-time project metrics

## Mock Data

The app includes realistic mock data for 4 sample projects:

1. **BlockDAG Network** - Verified (9.2/10 trust score)
2. **DAGSwap** - Under Review (7.8/10 trust score)
3. **DAGFi Protocol** - Verified (8.9/10 trust score)
4. **DAGGames** - Unverified (4.2/10 trust score)

## Technology Stack

- **Frontend**: Flutter Web
- **State Management**: StatefulWidget (ready for Provider/Riverpod)
- **Styling**: Material Design 3 + Custom Theme
- **Fonts**: Google Fonts (Inter)
- **Icons**: Material Icons
- **Data**: Mock service (ready for real API integration)

## Future Enhancements

- [ ] Web3 wallet integration (MetaMask, WalletConnect)
- [ ] Real API integration with backend services
- [ ] Content creator analytics dashboard
- [ ] Twitter API integration for social metrics
- [ ] Real-time price updates
- [ ] User authentication and profiles
- [ ] Project submission and verification workflow
- [ ] Mobile app version (iOS/Android)

## Contributing

This is a prototype implementation of the TrustSeal concept. The codebase is structured to be easily extensible for additional features and real API integration.

## License

This project is part of the TrustSeal ecosystem for BlockDAG verification.