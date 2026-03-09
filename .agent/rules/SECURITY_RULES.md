---
trigger: always_on
---

# 🔒 Repository Security Rules

These are mandatory security practices for anyone working on the HypeGrid repository.

---

## 1. Environment Variable Protection

- **NEVER** commit `.env` or `.env.local` files.
- **PROACTIVELY** verify that any API keys or client secrets are added to `.gitignore`.
- **Project-specific sensitive files:**
    - `ios/Runner/GoogleService-Info.plist` (If Firebase is added)
    - `android/app/google-services.json` (If Firebase is added)
    - `.env` (Containing `SUPABASE_KEY`, `API_FOOTBALL_KEY`, etc.)

---

## 2. No Hardcoded Secrets

- **NEVER** hardcode API keys, Firebase secrets, or private keys directly in Dart code.
- **USE** `--dart-define` or a package like `flutter_dotenv` for configuration.
- **DOCUMENT** all required environment variables in `.env.example`.

---

## 3. Git Hygiene

- **VERIFY** staged changes with `git status` before any commit.
- **DO NOT** use `git add .` blindly. Stage intentionally.
- **Target .gitignore entries:**
    ```
    .env
    .dart_tool/
    build/
    *.g.dart (if using code generation, depends on project choice)
    ```

---

## 4. Leak Remediation

If a secret is accidentally committed:
1. **REVOKE** the key immediately.
2. **ROTATE** the secret in the relevant console (Google Cloud, AWS, etc.).
3. Remove the sensitive commit using `git filter-repo`.

---

## 5. Firebase Security (If applicable)

- **NEVER** use "test mode" with open rules for production Firestore/Storage.
- **ALWAYS** restrict access based on auth status.

---

*Failure to follow these rules is a critical security violation.*
