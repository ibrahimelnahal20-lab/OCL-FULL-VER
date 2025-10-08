<!--
Guidance for AI coding agents working on this Flutter + GetX codebase.
Keep this short, actionable and codebase-specific. Update when routing, API
endpoints or storage keys change.
-->
# Copilot instructions (project-specific)

This Flutter app uses GetX for state, routing and dependency injection, Dio for
HTTP, and GetStorage for local persistence. Use the notes below to make
targeted, safe edits.

- Big picture
  - Architecture: Flutter UI (lib/) + GetX controllers (many under lib/). The
    app bootstraps controllers and services in `lib/main.dart` and
    `lib/initial_binding.dart`.
  - Networking: `lib/API/API.dart` centralizes Dio with a base URL,
    interceptors that add the `Authorization: Bearer <token>` header from
    `GetStorage` key `token`, and helper methods `getData`, `postData`,
    `putData`, `patchData`, `deleteData`.
  - Routing & guards: `lib/routes/routes.dart` defines `AppRoutes` and an
    `AuthGuard` middleware that uses `TopBarController.userType` to restrict
    pages. Many pages use `GetPage(..., middlewares: [AuthGuard()])`.

- Critical developer workflows
  - Build & run: standard Flutter commands apply. Typical quick commands:
    - flutter pub get
    - flutter run (or flutter run -d chrome for web)
  - Tests: see `test/widget_test.dart` (uses GetStorage init). Run with
    `flutter test`.
  - Debugging API: the base URL is in `lib/API/API.dart`. The app shows
    errors via `Get.snackbar(...)` (see `_handleError`). When changing API
    shapes, update controllers that call `API.getData/..` (search for
    `EndPoints.`).

- Project-specific conventions and useful patterns
  - Dependency injection: controllers are created with `Get.put(...)`. Some
    are `permanent: true` (see `main.dart` and `initial_binding.dart`). Don't
    duplicate permanent controllers; prefer `Get.find<Controller>()` to reuse.
  - Local storage keys: the token is stored with key `token` in `GetStorage`.
    Many controllers read it directly (search for `box.read('token')`).
  - API endpoints: See `class EndPoints` in `lib/API/API.dart`. Use these
    constants instead of string literals so changes remain centralized.
  - Error UX: network and API errors call `Get.snackbar` or the project's
    `widgets/enhanced_snackbar.dart`. Follow that pattern for consistent UX.

- Integration & cross-component notes
  - Auth flow: `LoginController` posts to `EndPoints.login`, saves `token`,
    and calls `_checkIn`. After login the `TopBarController` holds `userType`
    and `loggedInUsername` used by `AuthGuard` and user-profile widgets.
  - Images/uploads: API patch for multipart uses `patchImageWeb` in
    `API.dart` (Content-Type: multipart/form-data). For web, `image_picker_web`
    is included.

- When editing code, follow these concrete rules
  1. If you change an API endpoint or response shape, update `lib/API/API.dart`
     and then all callers that use that endpoint (`grep EndPoints.`).
  2. Use `Get.put(...)` only in startup code or page constructors. Prefer
     `Get.find<T>()` to access existing controllers.
  3. Keep UI changes isolated to `lib/...` files. When altering controller
     state, ensure `update()` or Rx types are used consistently (project is
     GetX-heavy).
  4. Preserve `GetStorage` keys (`token`) unless intentionally renaming;
     changing them requires a migration path.

- Quick file references (examples)
  - App bootstrap: `lib/main.dart` — initializes `GetStorage`, registers
    controllers, calls `API.init()`.
  - API wrapper & endpoints: `lib/API/API.dart` — base URL, interceptors,
    helper methods, and `_handleError` → `Get.snackbar`.
  - DI bindings: `lib/initial_binding.dart` — initial `Get.put` calls.
  - Routes & guards: `lib/routes/routes.dart` — `AppRoutes`, `AuthGuard`.

If any section is unclear or you want more examples (e.g., controller
templates or how to run specific pages in web mode), tell me which parts to
expand and I will iterate.
