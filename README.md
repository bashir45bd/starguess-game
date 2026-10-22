# StarGuess Flutter App

Flutter mobile client for StarGuess. Screens follow the supplied dark slate and gold UI reference. The app is organized by feature with repositories, an app-level state store, a shared API client, and server-driven game configuration.

## Local development

1. Start the PHP/MySQL API using the setup guide in `C:\xampp\htdocs\starguess-admin\README.md`.
2. Run on the Android emulator:

   ```powershell
   flutter pub get
   flutter run --dart-define=API_URL=http://10.0.2.2/starguess-admin/api/v1
   ```

3. For a device on the same Wi-Fi, use the computer's LAN address as `API_URL` for debug only. Profile/release builds reject non-HTTPS API URLs. Set the production endpoint at build time, for example:

   ```powershell
   flutter build appbundle --release --dart-define=API_URL=https://api.your-domain.example/starguess-admin/api/v1
   ```

Configure Android release signing through `STARGUESS_KEYSTORE_FILE`, `STARGUESS_KEYSTORE_PASSWORD`, `STARGUESS_KEY_ALIAS`, and `STARGUESS_KEY_PASSWORD`; never commit a keystore or its credentials. Release builds enable code and resource shrinking. For obfuscated releases, use `--obfuscate --split-debug-info=build/symbols` and keep the symbols private for crash decoding.

## App structure

- `lib/core`: API client, theme, and shared app state.
- `lib/features`: auth, home, matches, wallet, leaderboard, history, profile, and information screens.
- `lib/shared`: common navigation and UI widgets.
- `assets/images`: artwork copied from the supplied UI reference project.

The backend supports account recovery, wallet, configuration, history, private/quick match, leaderboard periods, and basic support/reward flows. Password recovery requires PHP mail delivery configured with `MAIL_FROM`. Payment gateway checkout, push/live match updates, secure persistent sessions, and some game modes still require completion before store release. Login locks an account for 15 minutes after five failed attempts; sessions expire after eight hours. The app keeps session tokens in memory only; closing the process signs the user out. Stars and outcomes displayed by the app are read from the backend; never treat the client as payment or result authority.

The four bundled images are optimized copies; the original artwork remains in `assets/images` but is excluded from the app bundle.
