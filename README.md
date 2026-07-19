# Incue — Doctor Desktop

Incue Doctor is a cross‑platform clinic management application that lets doctors run
their day‑to‑day practice — appointments, live patient queues, prescriptions, patient
records, reviews and scheduling — from a single app. It is built with **Flutter** and
talks to a REST backend hosted on Google Cloud Run.

The repository also contains the marketing/landing site that is served through
**Firebase Hosting**.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Installation & Running](#installation--running)
- [Configuration & Environment Variables](#configuration--environment-variables)
- [Testing](#testing)
- [Deployment](#deployment)
- [API Overview](#api-overview)

---

## Features

- **Authentication** — OTP‑based phone sign‑up, login, password reset and change
  password flows.
- **Doctor onboarding** — multi‑step profile creation (personal details, clinic
  details, specialization, consultation fees, working hours).
- **Live patient queues** — real‑time *waiting*, *reached* and *current patient*
  queues with "send in", "reached" and "send next" controls.
- **Bookings** — create single, multiple and walk‑in bookings, view booking history,
  cancel bookings and see estimated wait times / earliest available slots.
- **Prescriptions** — build prescriptions with a searchable medicine database,
  reusable prescription templates, and configurable print ratios for direct printing.
- **Patient management** — add / edit patients, search patients by phone number, and
  browse full per‑patient booking history.
- **Vitals & treatment notes** — record patient vitals, treatment notes and attach /
  view / delete medical files.
- **Scheduling** — manage leaves, reschedule appointments and reschedule clinic
  timings.
- **Reviews & feedback** — view patient reviews and collect feedback.
- **Billing** — track and update patient balances / dues.
- **Responsive UI** — separate mobile and web/desktop layouts (e.g. `homeScreen` vs
  `homeScreen web`).

---

## Architecture

Incue Doctor is a client application; all business data is persisted by a remote REST
service.

```
┌───────────────────────────────────────────────┐
│                 Flutter Client                  │
│                                                 │
│  UI Layer            screens/ (+ components/)    │
│  State Management    provider + riverpod         │
│  Domain Models       Models/                     │
│  Networking          http.Client, components/    │
│                      urls.dart (endpoints)       │
│  Local Persistence   shared_preferences          │
└───────────────────────┬─────────────────────────┘
                         │  HTTPS / JSON
                         │  (HTTP Basic auth)
                         ▼
        ┌────────────────────────────────┐
        │   Incue REST API (Cloud Run)    │
        │  incue-oep43kcksq-el.a.run.app  │
        └────────────────────────────────┘

        ┌────────────────────────────────┐
        │   Landing site (Firebase Host)  │
        │        served from  n/          │
        └────────────────────────────────┘
```

Key architectural points:

- **UI layer** lives under `doctor/lib/screens`, with each screen broken into a folder
  containing the screen widget, a `components/` sub‑folder and, in most cases, a
  `requests.dart` file holding that screen's API calls.
- **State management** uses both `provider` (`ChangeNotifierProvider` for
  `ConnectionService` and `AppointmentProvider`) and `riverpod` for finer‑grained,
  screen‑local state (notably on the prescription screen).
- **Domain models** in `doctor/lib/Models` are plain Dart classes with
  `fromJson` / `toJson` factories.
- **Networking** is centralized in `doctor/lib/components/urls.dart`, which defines the
  base URL, every endpoint, the shared auth `header`, and app‑wide singletons such as
  `myProfile` and `metaData`.
- **Authentication** uses HTTP Basic auth: the doctor's phone number and password are
  base64‑encoded into the `authorization` header (`initializeHeader()`), and login
  state is cached in `shared_preferences`.

---

## Project Structure

```
doctor-desktop/
├── doctor/                 # Flutter application (primary project)
│   ├── lib/
│   │   ├── main.dart       # App entry point, provider tree, routing
│   │   ├── Models/         # Domain models (Doctor, Appointment, Patient, ...)
│   │   ├── providers/      # ChangeNotifier / global providers
│   │   ├── components/     # urls.dart — API endpoints, headers, globals
│   │   ├── screens/        # Feature screens (login, home, bookings, ...)
│   │   └── trash/          # Deprecated / legacy screens
│   ├── android/  ios/  web/ macos/ windows/   # Platform runners
│   ├── assets/             # Fonts, images, icons
│   ├── test/               # Widget tests
│   └── pubspec.yaml        # Dart/Flutter dependencies
├── n/                      # Static landing site (Firebase Hosting public dir)
├── firebase.json           # Firebase Hosting config (root site)
└── .firebaserc             # Firebase project aliases
```

---

## Installation & Running

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Dart SDK
  `>=2.12.0 <3.0.0`, i.e. Flutter 3.x)
- Xcode (for iOS/macOS) and/or Android Studio + Android SDK (for Android)
- A configured device, emulator or simulator
- (Optional) [Firebase CLI](https://firebase.google.com/docs/cli) for deploying the
  landing site

### Setup

```bash
git clone https://github.com/udbajaj7/doctor-desktop.git
cd doctor-desktop/doctor

# Install dependencies
flutter pub get
```

### Run

```bash
# List available devices
flutter devices

# Run on the default connected device
flutter run

# Or target a specific platform
flutter run -d chrome      # web
flutter run -d macos       # macOS desktop
flutter run -d <device-id> # a specific device/emulator
```

### Build release artifacts

```bash
flutter build apk            # Android APK
flutter build appbundle      # Android App Bundle (Play Store)
flutter build ios            # iOS
flutter build web            # Web
```

Launcher icons can be regenerated with:

```bash
flutter pub run flutter_launcher_icons
```

---

## Configuration & Environment Variables

This project does **not** use `.env` files. Runtime configuration is defined in code
and in per‑platform files:

| Setting | Location | Notes |
|---|---|---|
| API base URL (`siteUrl`) | `doctor/lib/components/urls.dart` | Points to the Cloud Run backend. Change here to target another environment. |
| API endpoints | `doctor/lib/components/urls.dart` | Derived from `siteUrl` / `docUrl`. |
| Auth credentials | Runtime (via `shared_preferences`) | Phone number + password captured at login, base64‑encoded into the Basic auth header by `initializeHeader()`. |
| App version | `doctor/pubspec.yaml` (`version:`) | `versionName` / `versionCode` for stores. |
| Firebase project | `.firebaserc` | Aliases `default` / `prod` → `incue-desktop`. |
| Hosting public dir | `firebase.json` | Serves the `n/` directory. |

> To point the app at a different backend (e.g. staging), edit `siteUrl` in
> `doctor/lib/components/urls.dart`.

---

## Testing

Tests live in `doctor/test`.

```bash
cd doctor

# Run the full test suite
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Static analysis / linting
flutter analyze
```

---

## Deployment

### Mobile & desktop app

Build the appropriate release artifact (see [Build release artifacts](#build-release-artifacts))
and distribute it through the relevant store or channel:

- **Android** — upload the App Bundle from `flutter build appbundle` to Google Play.
- **iOS** — archive/upload via Xcode after `flutter build ios`.

### Landing site (Firebase Hosting)

The static site in `n/` is deployed with the Firebase CLI using the config in
`firebase.json` and `.firebaserc`:

```bash
# From the repository root
firebase login
firebase deploy --only hosting            # deploys to the default project (incue-desktop)
firebase deploy --only hosting -P prod    # deploys to the 'prod' alias
```

---

## API Overview

The client communicates with the Incue REST API over HTTPS with JSON payloads.

- **Base URL:** `https://incue-oep43kcksq-el.a.run.app/`
- **Auth:** HTTP Basic (`authorization: Basic base64(phone:password)`) on authenticated
  endpoints; auth endpoints are unauthenticated.
- **Content type:** `application/json`

All endpoints are defined in `doctor/lib/components/urls.dart`. Representative
endpoints, grouped by area:

### Authentication & Account
| Purpose | Endpoint |
|---|---|
| Send OTP | `POST /send_otp/` |
| Resend OTP | `POST /resend_otp/` |
| Verify OTP | `POST /verify_otp/` |
| Login | `POST /login/` |
| Change password | `POST /change_pwd/` |
| Forgot‑password OTP | `POST /forget_pwd_send_otp/` |
| List cities | `GET /cities/` |

### Doctor Profile
| Purpose | Endpoint |
|---|---|
| Add doctor | `POST /doctor/addDoctor/` |
| Get doctor info | `POST /doctor/getDocInfo/` |
| Edit profile | `POST /doctor/editProfile/` |
| Get available treatments | `POST /doctor/getTreatments/` |

### Queues & Appointments
| Purpose | Endpoint |
|---|---|
| Waiting queue | `POST /doctor/getWaitingQueue/` |
| Reached queue | `POST /doctor/getReachedQueue/` |
| Current patient | `POST /doctor/getCurrentPatient/` |
| Reached button | `POST /doctor/reachedBtn/` |
| Send‑in button | `POST /doctor/sendInBtn/` |
| Send next | `POST /doctor/sendNext/` |
| End appointment | `POST /doctor/endBooking/` |

### Bookings & Scheduling
| Purpose | Endpoint |
|---|---|
| Add booking | `POST /doctor/addBooking/` |
| Add multiple bookings | `POST /doctor/addBookingMultiple/` |
| Cancel booking | `POST /doctor/cancelBooking/` |
| Get bookings | `POST /doctor/getBookings/` |
| Estimated time | `POST /patient/getEstTime/` |
| Earliest slot | `POST /doctor/getEarliestSlot/` |
| Available slots / dates | `POST /doctor/getSlots/`, `POST /doctor/getAvalDates/` |
| Add / delay reschedule | `POST /doctor/addReschedule/`, `POST /doctor/addDelay/` |
| Leaves | `POST /doctor/addLeave/`, `POST /doctor/getLeaves/`, `POST /doctor/deleteLeave/` |
| Clinic timing reschedule | `POST /doctor/addRescheduleTimings/`, `POST /doctor/getRescheduledTimings/`, `POST /doctor/deleteRescheduleTimings/` |

### Patients, Vitals & Files
| Purpose | Endpoint |
|---|---|
| All patients | `POST /doctor/getAllPatients/` |
| Search patient | `GET /doctor/searchPatient/?phone_number=` |
| Edit patient | `POST /doctor/editPatientInfo/` |
| All patient bookings | `POST /doctor/getAllBookings/` |
| Get / save vitals | `POST /doctor/getVitals/`, `POST /doctor/saveVitals/` |
| Treatment notes | `POST /doctor/addTreatmentNotes/`, `POST /doctor/editTreatment/` |
| Treatment files | `POST /doctor/addTreatmentFiles/`, `POST /doctor/getTreatmentFiles/`, `POST /doctor/deleteTreatmentFiles/` |

### Prescriptions
| Purpose | Endpoint |
|---|---|
| Medicine data | `POST /doctor/getMedicineData/`, `POST /doctor/saveMedicineData/` |
| Save prescription | `POST /doctor/savePrescription/` |
| Get prescription | `POST /doctor/getPrescription/`, `POST /doctor/getCurrentPresciption/` |
| Prescription templates | `POST /doctor/savePrescTemplate/`, `POST /doctor/getPrescTemplate/` |
| Print ratios | `POST /doctor/getPrescPrintRatios/` |

### Reviews & Billing
| Purpose | Endpoint |
|---|---|
| Get reviews | `POST /doctor/getReviews/` |
| Write feedback | `POST /doctor/writeFeedback/` |
| Get / update balance | `POST /doctor/getBalance/`, `POST /doctor/updateBalance/` |
