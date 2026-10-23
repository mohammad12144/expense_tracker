# Demo Script (~4 min)

1. **Intro (20s)** - "Expense Tracker: Flutter + Firebase + Riverpod. I'll show the flow, offline mode, push, and the build/CI."
2. **Auth (30s)** - Register or log in. Mention the token is stored in secure storage.
3. **Expenses (60s)** - Add an expense; show it appear instantly. Use search and a category filter. Point at the Total and This month cards.
4. **Offline (60s)** - Turn Wi-Fi off. Show the "Offline - showing saved data" banner and that the list still loads. Add an expense offline, turn Wi-Fi on, and show it sync.
5. **Paging (20s)** - Show "Load more (20 of N)".
6. **Push (30s)** - Send a test message from Firebase Console; click the notification and show the deep link screen.
7. **Build and CI (40s)** - Show the green GitHub Actions run (test + build-android) and the signed `app-prod-release.apk`.
8. **Wrap-up (20s)** - Architecture in one sentence, known limits (shared applicationId, web-tested only), and next steps (Firestore rules, per-flavor ids).