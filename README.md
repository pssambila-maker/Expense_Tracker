# WiseSteward - Advanced Expense Tracker

A beautiful, feature-rich expense tracking app built with Flutter. Track, search, filter, and analyze your spending with an intuitive interface and powerful features.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

## ✨ Features

### 💰 Expense Management
- **Add Expenses**: Quick and easy expense entry
- **Edit Expenses**: Tap any expense to modify it
- **Delete with Undo**: Swipe left to delete, with 4-second undo window
- **Duplicate Expenses**: Long press to quickly duplicate recurring expenses
- **Categories**: Organize into Food, Travel, Leisure, and Work

### 🔍 Search & Filter
- **Real-time Search**: Find expenses instantly by title
- **Category Filters**: Beautiful filter chips for each category
- **Combined Filtering**: Search and category filters work together
- **Dynamic Totals**: See filtered amounts update live
- **Smart Empty States**: Clear messaging when no results found

### 📊 Analytics & Visualization
- **Visual Charts**: Bar chart showing spending by category
- **Total Spending**: Large, clear display of totals
- **Expense Count**: Track number of expenses
- **Category Breakdown**: See spending distribution at a glance
- **Filtered Analytics**: Charts update based on active filters

### 💾 Data Management
- **Local Storage**: All data persisted locally using SQLite
- **CSV Export**: Export all expenses with one tap
- **Share Functionality**: Share exported CSV via any app
- **Pull-to-Refresh**: Swipe down to reload data
- **Auto-save**: Every change instantly saved

### 🎨 User Experience
- **Dark Mode**: Automatic dark mode support
- **Haptic Feedback**: Subtle vibrations for all interactions
- **Material Design**: Beautiful, modern interface
- **Responsive UI**: Works on all screen sizes
- **Loading States**: Smooth transitions and progress indicators
- **Error Handling**: User-friendly error messages

### 🎯 Smart Features
- **Long-press Menu**: Quick access to Edit, Duplicate, Delete
- **Tap-to-Edit**: Tap any expense for quick editing
- **Help System**: Interactive tutorial for swipe gestures
- **Persistent Preferences**: Remembers your hint preferences
- **Smart Hints**: Contextual help that appears when needed

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

## 📱 Usage Guide

### Adding an Expense

1. Tap the "Add Expense" floating button
2. Fill in the details:
   - **Title**: Name of the expense
   - **Amount**: Cost in dollars
   - **Date**: Select from date picker (up to 1 year back)
   - **Category**: Choose from dropdown
3. Tap "Save Expense"

### Editing an Expense

**Method 1: Quick Edit**
- Tap on any expense in the list

**Method 2: Long Press Menu**
- Long press on an expense
- Select "Edit" from the menu

### Deleting an Expense

**Method 1: Swipe to Delete**
- Swipe left on any expense
- Expense removed with 4-second undo window
- Tap "UNDO" to restore if needed

**Method 2: Long Press Menu**
- Long press on an expense
- Select "Delete"

### Duplicating an Expense

- Long press on any expense
- Select "Duplicate"
- A copy is created with "(Copy)" suffix and today's date

### Searching Expenses

1. Tap the search icon in the app bar
2. Type your search query
3. Results update in real-time
4. Tap X to clear search

### Filtering by Category

- Tap any category chip below the chart
- Tap "All" to remove filter
- Combine with search for powerful filtering

### Exporting Data

1. Tap the download icon in the header card
2. CSV file is generated with all expenses
3. Share dialog opens
4. Send via email, Drive, or any app

### Pull to Refresh

- Swipe down on the expense list
- Data reloads from database
- Useful after sync or data recovery

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry, dashboard, search, filters
├── models/
│   └── expense.dart          # Expense data model & enums
├── utils/
│   └── formatters.dart       # Shared date formatter
├── chart.dart                # Spending chart visualization
├── chart_bar.dart            # Individual chart bar component
├── new_expense.dart          # Add/Edit expense form modal
└── database_helper.dart      # SQLite CRUD operations
```

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Database**: SQLite (via sqflite package)
- **State Management**: StatefulWidget
- **UI**: Material Design 3
- **Persistence**: SharedPreferences for user preferences

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | SDK | UI framework |
| sqflite | ^2.4.2 | SQLite database |
| uuid | ^4.5.2 | Unique ID generation |
| intl | ^0.20.2 | Date formatting |
| path | ^1.9.1 | Path manipulation |
| csv | ^6.0.0 | CSV file generation |
| path_provider | ^2.1.5 | File system access |
| share_plus | ^10.1.2 | Share functionality |
| flutter_vibrate | ^1.3.0 | Haptic feedback |
| shared_preferences | ^2.3.3 | User preferences storage |

## 📊 Database Schema

```sql
CREATE TABLE user_expenses (
  id TEXT PRIMARY KEY,      -- UUID
  title TEXT,               -- Expense name
  amount REAL,              -- Cost
  date TEXT,                -- ISO8601 format
  category TEXT             -- Enum name (food, travel, leisure, work)
)
```

## 🎨 Theme

The app supports both light and dark themes:
- **Light Mode**: Purple accent (#605BB5)
- **Dark Mode**: Dark blue accent (#05637D)
- Automatic switching based on system preference

## 🔒 Privacy & Security

- ✅ All data stored locally on your device
- ✅ No internet connection required
- ✅ No data collection or tracking
- ✅ No analytics or third-party services
- ✅ Signing keys excluded from version control
- ✅ Export data anytime for backup

## 🎯 Feature Comparison

| Feature | Status |
|---------|--------|
| Add Expenses | ✅ Complete |
| Edit Expenses | ✅ Complete |
| Delete Expenses | ✅ Complete |
| Undo Delete | ✅ Complete |
| Duplicate Expenses | ✅ Complete |
| Search | ✅ Complete |
| Category Filters | ✅ Complete |
| Visual Charts | ✅ Complete |
| CSV Export | ✅ Complete |
| Share Exports | ✅ Complete |
| Pull-to-Refresh | ✅ Complete |
| Haptic Feedback | ✅ Complete |
| Dark Mode | ✅ Complete |
| Persistent Preferences | ✅ Complete |
| Error Handling | ✅ Complete |
| Long Press Menu | ✅ Complete |
| Empty States | ✅ Complete |
| Loading States | ✅ Complete |

## 🚧 Future Roadmap

Potential future enhancements:

- [ ] Budget tracking and goals
- [ ] Recurring expenses
- [ ] Multiple currencies
- [ ] Statistics and insights page
- [ ] Backup and restore to cloud
- [ ] Custom categories
- [ ] Date range filtering
- [ ] Multi-expense selection
- [ ] Expense attachments (receipts)
- [ ] Expense notes/descriptions
- [ ] Monthly/yearly reports
- [ ] Spending trends graph
- [ ] Category color customization
- [ ] Widget for home screen
- [ ] Biometric authentication

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
- All open-source contributors

## 🌟 Show Your Support

Give a ⭐️ if this project helped you!

---

**Built with ❤️ using Flutter**

### Version History

- **v1.0.0** (Initial Release)
  - Basic expense tracking
  - SQLite persistence
  - Dark mode support

- **v2.0.0** (Feature Complete) - Current
  - ✅ Edit expenses
  - ✅ Search functionality
  - ✅ Category filters
  - ✅ CSV export
  - ✅ Pull-to-refresh
  - ✅ Haptic feedback
  - ✅ Long-press menus
  - ✅ Duplicate expenses
  - ✅ SharedPreferences
  - ✅ Enhanced UX

## 💡 Tips & Tricks

1. **Quick Edit**: Tap any expense to edit it instantly
2. **Bulk Operations**: Long press for additional options
3. **Smart Search**: Search works with category filters
4. **Export Regularly**: Use CSV export for backups
5. **Pull to Refresh**: Keep data in sync
6. **Category Filters**: Quickly see spending by type
7. **Undo Delete**: Have 4 seconds to undo any deletion
8. **Duplicate**: Save time on recurring expenses

## ❓ FAQ

**Q: How do I edit an expense?**
A: Simply tap on any expense in the list to edit it.

**Q: Can I recover deleted expenses?**
A: Yes! You have 4 seconds to tap "UNDO" after deletion.

**Q: How do I export my data?**
A: Tap the download icon in the header card to export to CSV.

**Q: Does this app work offline?**
A: Yes! All data is stored locally, no internet needed.

**Q: How do I search for an expense?**
A: Tap the search icon in the top right corner.

**Q: Can I filter by multiple categories?**
A: Currently one category at a time, but you can combine with search.

**Q: Where is my data stored?**
A: Locally in SQLite database on your device.

---

**Happy Tracking! 📊💰**
