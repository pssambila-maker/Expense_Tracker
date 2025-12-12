# WiseSteward - Expense Tracker

A beautiful and intuitive expense tracking app built with Flutter. Track your spending across multiple categories with visual charts and persistent local storage.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

## ✨ Features

- **💰 Expense Management**: Add, view, and delete expenses with ease
- **📊 Visual Charts**: See your spending breakdown by category at a glance
- **🗂️ Categories**: Organize expenses into Food, Travel, Leisure, and Work categories
- **💾 Local Storage**: All data persisted locally using SQLite
- **🌙 Dark Mode**: Automatic dark mode support
- **↩️ Undo Delete**: Accidentally deleted an expense? Undo it within 4 seconds
- **📱 Responsive UI**: Beautiful Material Design interface that works on all screen sizes
- **🔒 Error Handling**: Robust error handling with user-friendly messages

## 📸 Screenshots

<!-- Add screenshots here when available -->

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.3 or higher)
- Dart SDK
- Android Studio / VS Code
- An Android/iOS device or emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/pssambila-maker/Expense_Tracker.git
cd Expense_Tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point & dashboard
├── models/
│   └── expense.dart          # Expense data model & enums
├── utils/
│   └── formatters.dart       # Shared utilities (date formatting)
├── chart.dart                # Spending chart visualization
├── chart_bar.dart            # Individual chart bar component
├── new_expense.dart          # Add expense form modal
└── database_helper.dart      # SQLite database operations
```

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Database**: SQLite (via sqflite package)
- **State Management**: StatefulWidget
- **UI**: Material Design

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | SDK | UI framework |
| sqflite | ^2.4.2 | SQLite database |
| uuid | ^4.5.2 | Unique ID generation |
| intl | ^0.20.2 | Date formatting |
| path | ^1.9.1 | Path manipulation |

## 📝 Usage

### Adding an Expense

1. Tap the floating action button (+)
2. Enter expense details:
   - Title: Name of the expense
   - Amount: Cost in dollars
   - Date: Select from date picker
   - Category: Choose from dropdown
3. Tap "Save Expense"

### Deleting an Expense

1. Swipe left on any expense in the list
2. The expense will be removed
3. Tap "UNDO" in the snackbar to restore it (available for 4 seconds)

### Viewing Analytics

- The chart at the top shows spending distribution across categories
- Bar height represents relative spending
- Icons below bars indicate categories
- Total spending is displayed below the chart

## 🎨 Theme

The app supports both light and dark themes:
- **Light Mode**: Purple accent (#605BB5)
- **Dark Mode**: Dark blue accent (#05637D)

## 📊 Database Schema

```sql
CREATE TABLE user_expenses (
  id TEXT PRIMARY KEY,
  title TEXT,
  amount REAL,
  date TEXT,
  category TEXT
)
```

## 🔒 Privacy & Security

- All data is stored locally on your device
- No internet connection required
- No data collection or tracking
- Signing keys excluded from version control

## 🚧 Roadmap

Future enhancements planned:

- [ ] Edit existing expenses
- [ ] Search and filter expenses
- [ ] Budget tracking and goals
- [ ] Export data to CSV
- [ ] Recurring expenses
- [ ] Multiple currencies
- [ ] Statistics and insights
- [ ] Backup and restore
- [ ] Custom categories

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👤 Author

**Paul Sambila**

- GitHub: [@pssambila-maker](https://github.com/pssambila-maker)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- sqflite package maintainers

---

Built with ❤️ using Flutter
