# WhereItWent; Personal Finance Tracker

A clean, offline-first Android app for tracking your spending, catching silent subscriptions, and staying ahead of your finances. Built with Flutter and Firebase.

---

## Features

### Dashboard
- Live balance card showing income, expenses, and net balance for the current period
- Daily spending card for non-essential categories, shows your daily allowance and flags overspending
- Quick-action buttons: add expense, scan a receipt, view spending breakdown, view silent drains
- Insight banners that surface patterns (e.g. top spending day, largest category)

### Expense Tracking
- Add expenses with category, description, date, and amount
- Mark any expense as **recurring** (daily / weekly / monthly / yearly)
- **Bill splitting** — attach named participants to an expense and track who still owes
- **OCR receipt scanning** — point your camera at a receipt to pre-fill amount and description automatically

### Spending Breakdown
- Monthly split between **essentials** and **non-essentials**
- Visual progress bar per category relative to total spend
- Tap any category to move it between sections, your preference is saved to your account

### Spending Forecast
- Projects the next 3 months of recurring charges
- Expandable month cards showing each charge, amount, and recurrence frequency

### Silent Drains
- Automatically surfaces recurring expenses you may have forgotten about
- Shows true monthly and yearly cost so the impact is obvious
- Dismiss for 30 days or delete directly from the list

### Bill Splits
- Dedicated tab showing all outstanding splits across all expenses
- One-tap "Mark Settled" per person, state syncs to Firestore in real time

### Budget Settings
- Set budgets by category (not a single overall total)
- Choose weekly or monthly period
- Daily allowance is calculated automatically for non-essential categories

### Profile & Settings
- Account info and display name
- **Currency picker**: supports USD, BDT, AUD, GBP, EUR, CAD, SGD, INR
- Login & security (password change)
- Data & privacy controls
- Google Sign-In support

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Android, API 26+) |
| Language | Dart |
| State management | Riverpod 2 |
| Backend | Firebase Auth + Cloud Firestore |
| Auth | Email/password + Google Sign-In |
| OCR | Google ML Kit Text Recognition |
| Charts | fl_chart |
| Offline support | Firestore persistence (unlimited local cache) |

---

## Project Structure

```
lib/
├── core/           # Theme, constants, utility functions
├── models/         # Expense, Budget, SplitPerson data models
├── providers/      # Riverpod providers (auth, expenses, budget, currency, etc.)
├── services/       # Firestore service classes (expenses, budget, currency, drains)
└── screens/
    ├── auth/           # Login & registration
    ├── onboarding/     # First-launch walkthrough
    ├── dashboard/      # Home screen and balance card
    ├── expenses/       # Add/edit expense sheet with OCR
    ├── breakdown/      # Spending breakdown screen
    ├── forecast/       # 3-month forecast
    ├── drains/         # Silent drains detector
    ├── splits/         # Bill splits tracker
    ├── profile/        # Profile, budget, currency, security settings
    └── shell/          # Bottom nav shell
```

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.2.3`
- Android Studio or VS Code with the Flutter extension
- A Firebase project with **Authentication** and **Firestore** enabled

### Setup

1. Clone the repo
   ```bash
   git clone https://github.com/sajid9505/whereitwent.git
   cd whereitwent
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Connect Firebase
   - Create a project in the [Firebase Console](https://console.firebase.google.com)
   - Add an Android app with your package name
   - Download `google-services.json` and place it in `android/app/`
   - Enable **Email/Password** and **Google** sign-in methods under Authentication
   - Create a Firestore database (start in production mode)

4. Add Firestore security rules (see below)

5. Run
   ```bash
   flutter run
   ```

---

## License

MIT
