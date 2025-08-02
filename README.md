Product Manager
Product Manager is a Flutter application with a Node.js backend and MySQL database for efficient product management. It allows users to view, add, edit, delete, search, sort, and export product data with a clean, responsive UI.

Features
Paginated Product List: 10 items per page with < and > navigation, showing only current page data.

Add Products: Instantly added to the top of the list (newest first).

Edit/Delete: Manage products via a 3-dot menu with confirmation prompts.

Search: Debounced (500 ms) filter by product name.

Sort: Sort by ID, name, price, or stock (ascending/descending).

Export: Download current product list as PDF or CSV.

Responsive UI: Teal theme, pagination controls, error handling, and loading indicators.

Technologies Stack
Frontend: Flutter (Provider, HTTP, PDF & CSV export libraries)
Backend: Node.js + Express.js
Database: MySQL