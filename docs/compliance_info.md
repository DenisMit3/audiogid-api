
# Compliance Information

## Data Safety (Google Play)
Audiogid collects the following data types:

1.  **Location** (Permissions: `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION` if opted-in)
    *   **Data Type**: Approximate location, Precise location
    *   **Purpose**: App functionality (Tour Mode, Nearby places)
    *   **Sharing**: No, data is processed on device and optional backend logs (anonymized)
    *   **Processing**: Ephemeral (not stored historically on server by default)

2.  **Financial Info** (Purchases)
    *   **Data Type**: Purchase history
    *   **Purpose**: App functionality (Access control)
    *   **Sharing**: Shared with payment providers (Google Play Billing) for processing

3.  **App Activity**
    *   **Data Type**: App interactions, Installed apps (Queries for deep linking if applicable)
    *   **Purpose**: Analytics
    *   **Sharing**: Firebase Analytics (Google)

4.  **Identifiers**
    *   **Data Type**: Device ID (Instance ID)
    *   **Purpose**: Analytics, Fraud prevention, Account management
    *   **Sharing**: Firebase

*   **Encryption**: All data in transit is encrypted (HTTPS).
*   **Deletion**: Users can request account deletion (App settings > Delete Account).

## App Privacy (App Store)
*   **Data Used to Track You**: None
*   **Data Linked to You**: 
    *   **Purchases**: Purchase History
    *   **Identifiers**: User ID
*   **Data Not Linked to You**:
    *   **Usage Data**: Product Interaction
    *   **Diagnostics**: Crash Data
    *   **Location**: Coarse Location

## Reviewer Credentials (Demo Account)
Use these credentials to bypass SMS verification during review:
*   **Phone**: `+79000000000`
*   **OTP Code**: `123456`

This account is pre-configured with test purchases if needed, or can be used to test the purchase flow in Sandbox.
