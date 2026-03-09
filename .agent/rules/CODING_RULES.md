---
trigger: always_on
---

# CODING_RULES

## General Principles

- **Business Logic:** Must reside in **BLoCs** or **Services**. Widgets should never contain complex logic or calculations.
- **Component Responsibility:** Widgets should focus on rendering and event delegation (e.g., adding events to BLoCs).
- **Dart & Clean Code:** Use strong typing. Avoid `dynamic`. Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
- **Python (Sync Script):** Use `requests` or `httpx` for API calls. Ensure robust error handling for external APIs. Follow [PEP 8](https://peps.python.org/pep-0008/).

---

## Styling

- **AppTheme & AppColors:** Always use tokens from `AppColors` or the current `Theme.of(context)`. Never hardcode hexadecimal color values in widgets.
- **Responsive Layouts:** Use `LayoutBuilder` or `MediaQuery` where necessary, but prefer flexible widgets like `Expanded`, `Flexible`, and `BoxConstraints`.
- **Spacing:** Use `SizedBox` with standard constants if defined, or follow a consistent grid (e.g., multiples of 4 or 8).

---

## Icons/Assets

- **Standard Icons:** Use Material `Icons` or `CupertinoIcons`.
- **Assets:** Place images in `assets/images/` and ensure they are declared in `pubspec.yaml`.
- **Naming:** use `snake_case` for asset filenames.

---

## Navigation

- **Navigator:** Use `Navigator.of(context).push()` or `pushReplacement()`.
- **Scoping:** Ensure BLoCs are provided to the routes that need them using `BlocProvider`.

---

## State Management

- **flutter_bloc:** The primary tool for state management.
- **Events & States:** Follow the `[Feature]Event` and `[Feature]State` pattern. States should be immutable (use `Equatable`).
- **Persistence:** Use `hydrated_bloc` if persistence is needed for specific states.

---

## Naming Conventions

| Type         | Convention   | Example                               |
|--------------|-------------|---------------------------------------|
| **BLoCs**    | PascalCase + Bloc | `HomeBloc`                        |
| **Widgets/Pages** | PascalCase | `GridCard.dart`, `HomeScreen.dart` |
| **Models**   | PascalCase | `UserRecord.dart`                    |
| **Files**    | snake_case  | `app_colors.dart`                    |
| **Variables/Methods** | camelCase | `isLoaded`, `fetchData()`     |

---

## File Organization

Follow categorical feature grouping:

```
/lib/pages/<feature_name>/
├── bloc/           # BLoC, Events, States
├── widget/         # Feature-specific sub-widgets
└── <feature>_screen.dart # Main screen entry
```

---

## DO NOT

- ❌ Do not use arbitrary color values (e.g., `Color(0xFF123456)`). Use `AppColors`.
- ❌ Do not put business logic or API calls inside `build()` methods.
- ❌ Do not use `setState()` for complex state that should be managed by a BLoC.
- ❌ Do not commit `pubspec.lock` if it creates version conflicts (though usually tracked).
