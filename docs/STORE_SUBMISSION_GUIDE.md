# 🚀 Store Submission Guide

This guide contains all the information you need to fill out the App Store Connect and Google Play Console forms.

## 📂 Assets & Text

*   **Russian Description & Titles:** [See PRODUCT_STORE_RU.md](./store/PRODUCT_STORE_RU.md)
*   **Privacy Policy:** [See PRIVACY_POLICY.md](./store/PRIVACY_POLICY.md)
*   **App Icon:** Generated in `apps/mobile_flutter/assets/store/icon.png` (Use this for store listing)

## 🛡️ Google Play Data Safety Form

**Data Collection & Security:**
*   Does your app collect or share any of the required user data types? **Yes**
*   Is all of the user data collected by your app encrypted in transit? **Yes**
*   Do you provide a way for users to request that their data is deleted? **Yes**

**Data Types:**

1.  **Location** -> **Precise Location**
    *   Collected? **Yes**
    *   Shared? **No**
    *   Processed Ephemerally? **No**
    *   Required? **No** (Users can deny, but tour mode requires it)
    *   Purpose: **App Functionality** (Navigation/Tours)

2.  **Personal Info** -> **User IDs**
    *   Collected? **Yes**
    *   Purpose: **App Functionality, Account Management**

3.  **Financial Info** -> **Purchase History**
    *   Collected? **Yes** (Via Google Play Billing)
    *   Purpose: **App Functionality**

4.  **Device or other IDs**
    *   Collected? **Yes**
    *   Purpose: **Analytics, App Functionality**

## 🍏 App Store Privacy (App Privacy Label)

1.  **Data Linked to You:**
    *   **Contact Info:** Email Address (if user signs up)
    *   **Purchases:** Purchase History
    *   **Identifiers:** User ID, Device ID

2.  **Data Not Linked to You:**
    *   **Usage Data:** Product Interaction
    *   **Diagnostics:** Crash Data

3.  **Location:**
    *   **Precise Location:** Used for App Functionality (Tours), linked to user identity (if logged in) or device ID.

## 🔑 Reviewer Access (Demo Account)

Create a user in the Admin Panel (`/users`) with the 'user' role for reviewers to test purchased content (or use Sandbox/TestFlight).
*   **Username:** demo@audiogid.app
*   **Password:** demo1234
*   **Notes:** "This account has purchased 'Historic Center' tour entitlement."

## 📸 Screenshots Checklist

You need 5-8 screenshots for each platform. Capture the following screens:
1.  **Home Screen** (Showing list of cities/tours)
2.  **Tour Detail** (Showing map preview & "Buy" button)
3.  **Map/Navigation** (Tour Mode with route)
4.  **POI Detail** (Showing photo & audio player)
5.  **Offline Manager** (Showing downloaded tours)

*Tip: Use a tool like https://studio.app-mockup.com/ to frame screenshots in devices.*
