# WiseSteward - User Manual

**Version 2.1.0**
**Comprehensive Expense Tracking Application**

---

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Dashboard Screen](#dashboard-screen)
4. [Expenses Screen](#expenses-screen)
5. [Daily View Screen](#daily-view-screen)
6. [Reports Screen](#reports-screen)
7. [Adding & Managing Expenses](#adding--managing-expenses)
8. [Exporting Data](#exporting-data)
9. [Tips & Best Practices](#tips--best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Introduction

WiseSteward is a powerful and intuitive expense tracking application designed to help you manage your personal finances effectively. With multi-screen navigation, detailed analytics, and flexible viewing options, tracking your spending has never been easier.

### Key Features

- **Multi-Screen Navigation**: Seamlessly switch between Dashboard, Expenses, Daily View, and Reports
- **Smart Search & Filtering**: Quickly find expenses by title or category
- **Week & Day Views**: Analyze spending patterns by day or week
- **Detailed Analytics**: Visualize spending with charts and category breakdowns
- **Data Export**: Export expenses to CSV for further analysis
- **Dark Mode Support**: Automatic light/dark theme based on system settings
- **Swipe Gestures**: Quick actions with intuitive swipe controls

---

## Getting Started

### First Launch

When you first open WiseSteward, you'll see the **Dashboard** screen. The app uses a bottom navigation bar with four main sections:

1. **Dashboard** (🏠) - Quick overview of your spending
2. **Expenses** (📝) - Manage all your expenses
3. **Daily** (📅) - Day and week-based views
4. **Reports** (📊) - Detailed analytics and export

### Navigation

Tap any icon in the bottom navigation bar to switch between screens. The app preserves your position in each screen, so you can easily switch back and forth without losing your place.

---

## Dashboard Screen

The Dashboard provides a quick snapshot of your spending across different time periods.

### Summary Cards

- **Today**: Total spending for the current day
- **This Week**: Total spending for the current week
- **This Month**: Total spending for the current month

### Recent Expenses

View your 10 most recent expenses with:
- Expense title
- Category icon
- Date
- Amount

### Quick Actions

- **View All Button**: Tap to navigate directly to the Expenses screen

---

## Expenses Screen

The Expenses screen is your central hub for managing all expense records.

### Search Functionality

1. Tap the **search icon** (🔍) in the top-right corner
2. Type your search query in the text field
3. Results filter in real-time as you type
4. Tap the **X icon** to exit search mode

**Search Tips**:
- Search is case-insensitive
- Searches expense titles only
- Combines with category filters

### Category Filters

Below the summary card, you'll find category filter chips:

- **All**: Show all expenses (default)
- **Food**: Restaurant meals, groceries
- **Travel**: Transportation, flights, hotels
- **Leisure**: Entertainment, hobbies
- **Work**: Office supplies, business expenses

**Using Filters**:
1. Tap any category chip to filter
2. Selected category is highlighted
3. Tap again or tap "All" to clear filter
4. Works with search - both filters apply together

### Summary Card

Displays at the top of the screen:
- **Total**: Sum of all visible expenses
- **Count**: Number of visible expenses

### Expense List

Each expense card shows:
- **Category Icon**: Visual category indicator
- **Title**: Expense description
- **Date**: When the expense occurred
- **Amount**: Dollar amount spent

### Chart Visualization

Interactive bar chart showing:
- Spending grouped by date buckets
- Visual comparison of spending patterns
- Updates based on current filters

### Managing Expenses

#### Adding a New Expense

1. Tap the **+ button** (floating action button)
2. Fill in the expense form:
   - **Title**: Description of the expense
   - **Amount**: Dollar amount (numbers only)
   - **Date**: Tap to select from calendar
   - **Category**: Choose from dropdown
3. Tap **Save Expense** to add
4. Or tap **Cancel** to discard

#### Editing an Expense

**Method 1 - Tap**:
1. Tap any expense card
2. Edit the details
3. Tap **Save Expense**

**Method 2 - Long Press**:
1. Long-press any expense card
2. Select **Edit** from the menu
3. Modify details and save

#### Duplicating an Expense

1. Long-press the expense card
2. Select **Duplicate** from the menu
3. A copy is created with the same details
4. Edit if needed or save as-is

#### Deleting an Expense

**Method 1 - Swipe**:
1. Swipe the expense card left or right
2. Confirm deletion
3. **Undo** option appears for 4 seconds
4. Tap **UNDO** to restore if needed

**Method 2 - Long Press**:
1. Long-press the expense card
2. Select **Delete** from the menu
3. Same undo option available

### Pull to Refresh

Pull down on the expense list to reload all data from the database.

---

## Daily View Screen

View expenses organized by individual days or entire weeks.

### View Mode Toggle

In the top-right corner, toggle between:
- **Day**: Single day view
- **Week**: Seven-day week view

### Day View Mode

#### Navigation

- **Left Arrow**: Go to previous day
- **Right Arrow**: Go to next day (disabled for today)
- **Date Display**: Tap to open date picker

#### Summary

- **Total**: Sum of expenses for the selected day
- **Expenses**: Count of expenses
- **Today Chip**: Appears when viewing current day

#### Chart

Visual bar chart showing spending by category for the selected day.

#### Expense List

Scrollable list of all expenses for that day, showing:
- Category icon in circular avatar
- Expense title
- Category name
- Amount

### Week View Mode

#### Navigation

- **Left Arrow**: Go to previous week
- **Right Arrow**: Go to next week
- **Date Range**: Shows start and end of week (e.g., "Dec 9 - Dec 15")

#### Weekly Summary

- **Total**: Sum of all expenses for the week
- **Expenses**: Total count for the week
- **Daily Avg**: Average spending per day (total ÷ 7)

#### Chart

Shows aggregated spending for the entire week.

#### Expandable Day Cards

Each day of the week is shown as a card:

**Card Header**:
- **Day Letter**: First letter in a circle (M, T, W, T, F, S, S)
- **Date**: Month and day (e.g., "Dec 9")
- **Today Chip**: Highlighted for the current day
- **Expense Count**: "X expense(s)"
- **Day Total**: Dollar amount

**Expanding Cards**:
1. Tap any day card to expand
2. View all expenses for that day
3. Shows individual expense details
4. Tap again to collapse

**Today Highlighting**:
- Elevated card with shadow
- Primary color background tint
- Bold text
- Stands out visually

---

## Reports Screen

Comprehensive analytics and data export capabilities.

### Report Tabs

Switch between two report types:
- **Monthly**: Current month analysis
- **Yearly**: Full year analysis

### Monthly Reports

#### Month Selector

- **Left Arrow**: Previous month
- **Right Arrow**: Next month (disabled for future months)
- **Month Display**: Current month and year

#### Summary Cards

**Row 1**:
- **Total**: Sum of all expenses for the month
- **Avg/Day**: Daily average spending
- **Count**: Number of expenses

**Row 2**:
- **Top Category**: Category with highest spending
  - Shows icon, name, and amount

#### Chart

Bar chart showing spending distribution across the month.

#### Category Breakdown

Detailed analysis of spending by category:

**For Each Category**:
- Category icon and name
- Total amount spent
- Percentage of total spending
- Visual progress bar

**Features**:
- Sorted by amount (highest to lowest)
- Color-coded progress bars
- Percentage calculations
- Easy visual comparison

#### All Expenses List

Scrollable list of every expense in the month:
- Category icon
- Title
- Date
- Amount

### Yearly Reports

Same features as monthly reports, but aggregated for the entire year:

#### Year Selector

- Navigate between years
- View historical data

#### Summary & Analysis

- Yearly totals and averages
- Top spending category for the year
- Full category breakdown
- All expenses for the year

### CSV Export

Export your expense data to a CSV file for use in spreadsheet applications.

**Steps to Export**:

1. Select desired time period:
   - Switch to **Monthly** or **Yearly** tab
   - Navigate to the specific month or year
2. Tap the **export icon** (📤) in the top-right corner
3. CSV file is generated with:
   - Date
   - Title
   - Category
   - Amount
4. Share dialog appears
5. Choose destination:
   - Email
   - Cloud storage (Google Drive, Dropbox, etc.)
   - Other apps

**CSV Format**:
```
Date,Title,Category,Amount
December 9, 2024,Lunch at Cafe,FOOD,15.50
December 10, 2024,Gas Station,TRAVEL,45.00
```

**File Naming**:
- Monthly: `expenses_December_2024.csv`
- Yearly: `expenses_2024.csv`

---

## Adding & Managing Expenses

### Creating an Expense

1. **Access the Form**:
   - Tap the **+** button on the Expenses screen
   - Or use the add button from any screen

2. **Fill Required Fields**:
   - **Title** (required): Descriptive name
     - Examples: "Grocery shopping", "Monthly rent", "Coffee"
   - **Amount** (required): Dollar amount
     - Enter numbers only (decimal allowed)
     - Examples: 15.50, 100, 1234.99

3. **Select Date**:
   - Tap the date field
   - Calendar picker appears
   - Select the date of the expense
   - Cannot select future dates

4. **Choose Category**:
   - Tap the category dropdown
   - Select from:
     - 🍽️ **Food**: Meals, groceries, dining
     - ✈️ **Travel**: Transportation, trips, gas
     - 🎮 **Leisure**: Entertainment, hobbies, fun
     - 💼 **Work**: Business, office, professional

5. **Save or Cancel**:
   - **Save Expense**: Adds the expense and closes form
   - **Cancel**: Discards changes and closes form

### Editing Expenses

**Quick Edit**:
1. Tap the expense card
2. Form opens with current values
3. Modify any field
4. Save changes

**Long Press Menu**:
1. Long-press the expense
2. Select "Edit"
3. Make changes
4. Save

### Bulk Actions

While WiseSteward doesn't have a traditional "select multiple" feature, you can:

1. **Duplicate Similar Expenses**:
   - Long-press an expense
   - Choose "Duplicate"
   - Modify the duplicate as needed

2. **Export to CSV**:
   - Use Reports screen
   - Export entire month or year
   - Manipulate in spreadsheet software

---

## Exporting Data

### CSV Export Options

#### Monthly Export

1. Go to **Reports** screen
2. Stay on **Monthly** tab
3. Navigate to desired month
4. Tap export icon (📤)
5. File includes all expenses for that month

#### Yearly Export

1. Go to **Reports** screen
2. Switch to **Yearly** tab
3. Navigate to desired year
4. Tap export icon (📤)
5. File includes all expenses for that year

### Sharing Options

After export, you can share via:

**Email**:
- Attach to email
- Send to yourself or others
- Import into desktop software

**Cloud Storage**:
- Google Drive
- Dropbox
- OneDrive
- iCloud Drive

**Other Apps**:
- Excel
- Google Sheets
- Numbers
- Any CSV-compatible app

### Using Exported Data

The CSV format is compatible with:

- **Microsoft Excel**: Open directly
- **Google Sheets**: Import via File → Import
- **Apple Numbers**: Open or import
- **Database Software**: Import for analysis
- **Accounting Software**: Many accept CSV import

**Analysis Ideas**:
- Create pivot tables
- Build custom charts
- Calculate tax deductions
- Budget planning
- Expense forecasting

---

## Tips & Best Practices

### Expense Entry

1. **Be Consistent with Titles**:
   - Use similar naming for recurring expenses
   - Examples: "Rent - December", "Rent - January"
   - Makes searching easier

2. **Enter Expenses Promptly**:
   - Add expenses when they happen
   - More accurate tracking
   - Don't forget small purchases

3. **Use Appropriate Categories**:
   - Food: All meals and groceries
   - Travel: All transportation
   - Leisure: Entertainment and hobbies
   - Work: Business and professional

4. **Round or Be Exact**:
   - Can round to nearest dollar for quick entry
   - Or enter exact amounts for precision
   - Stay consistent with your approach

### Organization

1. **Regular Review**:
   - Check Dashboard daily
   - Review Reports weekly
   - Identify spending patterns

2. **Category Distribution**:
   - Use Reports to see category breakdown
   - Identify areas to cut spending
   - Track progress over time

3. **Week View Benefits**:
   - See spending patterns across the week
   - Identify expensive days
   - Plan ahead for upcoming week

4. **Export Regularly**:
   - Monthly export for records
   - Backup your data
   - Tax preparation made easy

### Search & Filter

1. **Combine Search and Filters**:
   - Filter by category first
   - Then search within results
   - Narrow down quickly

2. **Search Keywords**:
   - Think of common words in titles
   - "coffee", "gas", "grocery"
   - Partial matches work

3. **Use Category Filters for Reports**:
   - See spending in specific categories
   - Compare categories month-to-month

### Data Management

1. **Regular Cleanup**:
   - Review old expenses
   - Delete test entries
   - Correct any mistakes

2. **Backup Strategy**:
   - Export monthly CSV files
   - Store in cloud storage
   - Keep yearly archives

3. **Privacy**:
   - Data stored locally on device
   - Exports only when you choose
   - No automatic cloud sync

---

## Troubleshooting

### Common Issues

#### Expenses Not Appearing

**Problem**: Added expense doesn't show in list

**Solutions**:
1. Pull down to refresh the list
2. Check active filters - may be filtered out
3. Clear search query
4. Select "All" category filter
5. Restart the app

#### Search Not Working

**Problem**: Search returns no results

**Solutions**:
1. Check spelling of search term
2. Remember: search is title-only
3. Try partial words instead of full phrases
4. Clear category filter if applied
5. Tap X to exit and re-enter search

#### Export Not Working

**Problem**: CSV export fails or doesn't share

**Solutions**:
1. Check device storage space
2. Ensure you have a file manager or email app
3. Try different sharing method
4. Check app permissions for storage
5. Restart the app and try again

#### Chart Not Displaying

**Problem**: Chart area is empty

**Solutions**:
1. Ensure expenses exist for the period
2. Pull down to refresh
3. Check date range
4. Verify expenses aren't filtered out

#### Date Picker Issues

**Problem**: Can't select dates

**Solutions**:
1. Future dates are disabled by default
2. Check if date is before year 2020 (minimum)
3. Restart the app
4. Try tapping date field again

### Performance Issues

#### App Runs Slowly

**Solutions**:
1. Close other apps to free memory
2. Restart the app
3. Clear old unnecessary expenses
4. Export and archive old data
5. Restart your device

#### Large Database

If you have thousands of expenses:

1. **Archive Old Data**:
   - Export yearly CSV files
   - Delete old expenses from app
   - Keep CSV files as records

2. **Filter More Aggressively**:
   - Use category filters
   - Search for specific items
   - View smaller date ranges

### Data Issues

#### Missing Expenses

If expenses seem to have disappeared:

1. Check all category filters
2. Clear search
3. Look in different months (Reports screen)
4. Check if accidentally deleted (can't undo after 4 seconds)

#### Duplicate Expenses

If you see duplicates:

1. May have added same expense twice
2. Check dates and amounts to confirm
3. Delete unwanted duplicates via swipe or long-press

#### Wrong Amounts

To fix incorrect amounts:

1. Tap the expense to edit
2. Update the amount field
3. Save changes
4. Charts and totals update automatically

### Getting Help

If issues persist:

1. **Check Version**: Ensure you have the latest version (2.1.0)
2. **Restart App**: Close completely and reopen
3. **Restart Device**: Sometimes needed for system issues
4. **Reinstall**: Uninstall and reinstall (⚠️ will lose data - export first!)
5. **Contact Support**: Through the Play Store listing

---

## Appendix

### Version History

**Version 2.1.0** (Current)
- Multi-screen navigation with bottom nav bar
- Dashboard with quick overview
- Enhanced Expenses screen with search and filters
- Week view in Daily screen
- Detailed Reports analytics with category breakdown
- Visual progress bars in Reports
- Top category card
- Improved UI/UX throughout

**Version 2.0.0**
- Initial public release
- Single screen expense tracker
- Basic add/edit/delete functionality
- Category support
- Charts and analytics
- CSV export
- Dark mode support
- Swipe to delete

### Keyboard Shortcuts

When using with physical keyboard or external keyboard:

- **Tab**: Navigate between fields in forms
- **Enter**: Submit forms
- **Escape**: Close dialogs and forms
- **Arrow Keys**: Navigate lists

### Accessibility

WiseSteward supports:

- **TalkBack**: Screen reader support
- **Large Text**: Respects system font size
- **High Contrast**: Dark mode for better visibility
- **Touch Targets**: Large tap areas for easy interaction

### Privacy & Security

- **Local Storage**: All data stored on your device
- **No Account Required**: Use without registration
- **No Ads**: Clean, ad-free experience
- **No Tracking**: No analytics or user tracking
- **Export Control**: You decide what to share

### Credits

**Developed by**: [Your Name/Team]
**Version**: 2.1.0
**Release Date**: December 2024
**Platform**: Android
**Minimum Android Version**: Android 5.0 (API 21)

---

## Contact & Support

**Google Play Store**: [WiseSteward on Play Store]

**Feedback**: Submit reviews and feedback through the Play Store

**Bug Reports**: Report issues via Play Store or GitHub

---

**Thank you for using WiseSteward!**

*Track smarter, spend wiser.*
