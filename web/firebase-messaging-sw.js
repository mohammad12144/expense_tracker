
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyA6eCL9TSUWKqyV9iuCilion736S-EkQus",
  authDomain: "expense-tracker-1ffb1.firebaseapp.com",
  projectId: "expense-tracker-1ffb1",
  storageBucket: "expense-tracker-1ffb1.firebasestorage.app",
  messagingSenderId: "529734910563",
  appId: "1:529734910563:web:c23d0795bcc56fdfdfee56",
});

const messaging = firebase.messaging();
