# Budget Tracker App

A comprehensive, user-friendly budget tracking application built with Flutter. It allows users to effortlessly record their daily income, expenses, and savings, manage their transaction history, and gain powerful insights into their financial habits through a clean and intuitive user interface.

## Features

*   **Complete Transaction Management:**
    *   **Add:** Easily add new transactions for expenses, income, or savings with details like category, amount, and date.
    *   **Edit & Delete:** Full capability to modify or remove any past transaction from a detailed history screen.
*   **Detailed Transaction History:**
    *   View all transactions in a clear, organized list.
    *   A tabbed interface neatly separates **Income**, **Expenses**, and **Savings** for quick access.
*   **Advanced Summary Dashboard:**
    *   Get an at-a-glance overview of your finances with interactive charts.
    *   **Expense Breakdown:** A pie chart visualizes spending by category.
    *   **Monthly Savings:** A bar chart tracks savings performance over time.
    *   **Spending Trends:** A line chart shows daily spending patterns.
    *   Details in the bar graph will show the amount spent in savings category by hovering it.
*   **Intelligent Budget Management:**
    *   When adding an expense that exceeds the monthly budget for a category, the app proactively offers to **transfer the shortfall from a savings category**, preventing the transaction from being blocked.
    *   Can add, set/edit, or delete budget category
*   **Monthly Filtering:**
    *   Filter the entire summary dashboard to view data for specific months or an overall summary of all time.
*   **App Personalization & Data Management:**
    *   **Dark Mode:** Switch between light and dark themes for comfortable viewing.
    *   **Data Reset:** A secure option to wipe all application data and start fresh.
*   **Notifications:**
    *   Receive a notification whenever a new transaction is added.
    *   A dedicated notification center to view and manage past notifications.
    *   An option to delete a specific notification.
    *   Can mark a specific notification as read by tapping on it and can mark all as read by tapping check icon.
*   **Responsive Design:**
    *   The user interface gracefully adapts to both standard phone screens and wider displays like tablets or phones in landscape mode.
*   **Offline First:**
    *   All data is stored locally on the device, ensuring the app is fully functional without an internet connection.

## Database

*   **Technology:** The app utilizes a local SQLite database, managed through the powerful `sqflite` package in Flutter.
*   **Offline-First Architecture:** All user data, including transactions, budgets, and settings, is stored directly on the device. This core design choice ensures the app is always available and responsive, regardless of internet connectivity.
*   **Data Privacy & Control:** By keeping all data on the user's device, the app ensures complete privacy. No financial information is ever sent to an external server. The user has full control over their data, with the ability to clear it at any time through the settings menu.
*   **Data Persistence:** The database provides robust and permanent storage for all financial records, ensuring that the user's history is maintained across app sessions.

## How to Use

1.  Launch the app to see your recent transactions on the home screen.
2.  Tap the **"+"** button to open the "Add Transaction" screen.
3.  Fill in the amount, select a category, date, and type (Expense, Income, or Savings), and tap **Save**.
4.  Navigate to the **Summary** tab to see your updated financial charts.
5.  Go to the **History** tab to view, edit, or delete any past transaction.
6.  Explore the **Settings** tab to switch to Dark Mode or reset your data.

### Home Screen
![HomeScreen.png](assets/images/HomeScreen.png)

### Manage Budget Screen
![ManageBudgetScreen.png](assets/images/ManageBudgetScreen.png)
![BudgetUpdateDialog.png](assets/images/BudgetUpdateDialog.png)

### Add Transaction Screen
![AddTransactionScreen.png](assets/images/AddTransactionDialog.png)
![AddExpenseScreen.png](assets/images/AddExpenseScreen.png)
![AddIncomeScreen.png](assets/images/AddIncomeScreen.png)
![AddSavingsScreen.png](assets/images/AddSavingsScreen.png)
![SavingsAmountTransferDialog.png](assets/images/SavingsAmountTransferDialog.png)

### Summary Screen
![SummaryScreen.png](assets/images/SummaryScreen1.png)
![SummaryScreen2.png](assets/images/SummaryScreen2.png)

### History Screen
![HistoryScreen.png](assets/images/TransactionHistoryScreen.png)
![TransactionHistoryScreen1.png](assets/images/TransactionHistoryScreen1.png)
![TransactionHistoryScreen2.png](assets/images/TransactionHistoryScreen2.png)
![EditTransactionScreen.png](assets/images/EditTransactionScreen.png)
![DeleteTransactionDialog.png](assets/images/DeleteTransactionDialog.png)

### Notification Screen
![NotificationScreen.png](assets/images/NotificationScreen.png)

### Settings Screen
![SettingsScreen.png](assets/images/SettingsScreen.png)

### DarkMode
![DarkMode.png](assets/images/DarkMode.png)
![DarkMode1.png](assets/images/DarkMode1.png)
![DarkMode2.png](assets/images/DarkMode2.png)
![DarkMode3.png](assets/images/DarkMode3.png)
![DarkMode4.png](assets/images/DarkMode4.png)
![DarkMode5.png](assets/images/DarkMode5.png)
![DarkMode6.png](assets/images/DarkMode6.png)


## Developer

This application was developed by :
- Janlee Estoy,
- Alaisa Maquilan,
- Gabriel Phoenix Serohijos
