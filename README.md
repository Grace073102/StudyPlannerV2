# CampusFlow

CampusFlow is an iOS student planning application that brings academic organisation, personal placement preparation, and internship discovery together. Students can manage assignments and tasks, track placement requirements, organise supporting documents, and save internship opportunities within one application.

CampusFlow is independently developed and is not affiliated with or officially connected to any university or university system. It supports personal organisation; official university systems remain responsible for placement allocation, approval, and compliance.

## Features

### Academic Planning

- Create, edit, and delete assignments.
- Organise assignments by subject.
- Break assignments into smaller tasks and track completion.
- View assignment progress and upcoming deadlines.
- Import, preview, and delete assignment PDFs.

### Placement Preparation

- Create and manage personal placement records.
- Track placement dates and preparation requirements.
- Record requirement deadlines and completion.
- Receive local reminders for placement requirements.
- View upcoming placement preparation tasks.

### Internship Discovery and Tracking

- Discover internship opportunities through the CleanJobData API.
- Search by title and filter for remote opportunities.
- Load additional results using cursor pagination.
- Open available company websites.
- Save discovered opportunities to Career → Internships.
- Add and manage saved internships manually.
- Track application status and prevent duplicate saves.

### PDF Sharing

- Share a PDF from another application to CampusFlow.
- Select an existing assignment to attach the PDF to.
- Access the imported PDF from the assignment’s detail screen.

## Architecture

CampusFlow uses SwiftUI for its interface and SwiftData for local persistence. ViewModels manage interface state and actions, use cases contain application-specific business rules, and repository protocols separate business logic from storage and API access.

```text
┌────────────────────────┐
│     SwiftUI Views      │
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│       ViewModels       │
│   UI state + actions   │
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│       Use Cases        │
│     Business rules     │
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│  Repository Protocols  │
└───────────┬────────────┘
            │
      ┌─────┴─────┐
      ▼           ▼
┌───────────┐ ┌─────────────────┐
│ SwiftData │ │ CleanJobData   │
│   Local   │ │ Internship API │
└───────────┘ └─────────────────┘
```

Internship searches use the discovery repository directly from the ViewModel. Saving an opportunity passes through a use case before reaching the SwiftData repository.

Academic records, placement information, and saved internships are stored locally. Live internship discovery requires an internet connection and API configuration.

## Domain Use Cases

| Use Case | Responsibility |
| --- | --- |
| `AddAssignmentUseCase` | Validates and creates assignments. |
| `UpdateAssignmentUseCase` | Validates changes to existing assignments. |
| `AddTaskUseCase` | Adds tasks to assignments. |
| `EditTaskUseCase` | Validates and updates task details. |
| `ManagePlacementsUseCase` | Manages placement records and coordinates reminder cancellation after deletion. |
| `AddRequirementUseCase` | Validates and creates placement requirements. |
| `ToggleRequirementCompletionUseCase` | Updates requirement completion status. |
| `ManageSavedInternshipsUseCase` | Validates saved internship details and rejects duplicate job IDs. |
| `SaveDiscoveredInternshipUseCase` | Converts an API listing into a locally saved internship. |
| `DocumentUseCase` | Manages assignment PDF documents. |

Validation and repository errors are passed back to the interface for display.

## System Extension and Services

| Component | Purpose |
| --- | --- |
| **Share Extension** | Imports PDFs shared from other applications and attaches them to an existing assignment. |
| **App Group storage** | Shares assignment summaries and PDF files between the main application and Share Extension. |
| **Local notification service** | Schedules and cancels placement requirement reminders. |

The main application and Share Extension use the App Group identifier `group.com.campusflow.shared`.

## Project Structure

```text
StudyPlannerV2/
├── StudyPlannerV2.xcodeproj
├── StudyPlannerV2/
│   ├── Configuration/
│   │   ├── Env.swift
│   │   └── Development.xcconfig.example
│   ├── Model/
│   ├── Views/
│   ├── ViewModels/
│   ├── UseCases/
│   ├── Repositories/
│   ├── Services/
│   └── Extension/
├── CampusFlowShareExtension/
├── StudyPlannerV2Tests/
│   └── MockRepositories/
└── StudyPlannerV2UITests/
```

## Requirements

- macOS with Xcode and an iOS 26.1 SDK or later.
- An iOS 26.1 or later simulator or compatible device.
- Internet access and a personal CleanJobData API key for live internship discovery.

For physical-device testing, configure signing for both the application and Share Extension. Both targets must have access to the same App Group.

## Running the Project

1. Clone the repository:

   ```sh
   git clone https://github.com/Grace073102/StudyPlannerV2.git
   ```

2. Open `StudyPlannerV2.xcodeproj` in Xcode.
3. Complete the API configuration below to enable internship discovery.
4. Select the **StudyPlannerV2** scheme.
5. Select a compatible iPhone simulator or connected device.
6. Build and run using **⌘R**.
7. Allow notifications when prompted if you want placement reminders.

Missing API configuration affects Discovery; locally stored planner data remains accessible.

## Internship API Configuration

Each developer supplies their own CleanJobData API key for local development.

1. Create a [CleanJobData account](https://cleanjobdata.com/) and obtain an API key.

2. Navigate to `StudyPlannerV2/Configuration/Development.xcconfig` and replace the placeholder with your key:

   ```text
   CLEANJOBDATA_API_KEY = YOUR_API_KEY_HERE
   ```

3. In Xcode, select the project, open **Info → Configurations**, and confirm that the app target’s **Debug** configuration uses `Development.xcconfig`.

4. Build and run using the Debug configuration.

The application reads the configured value through `Env.swift`.

Make sure not to commit your real API key to the GitHub repository.

This direct API configuration is intended for local development. A distributed application should keep the API credential on a server.

## Testing

Run the tests using **⌘U** in Xcode.

API repository tests use simulated responses and do not require a real API key or an internet connection. Persistence tests use in-memory storage or mock repositories.

Coverage includes:

- Assignment and task validation.
- Placement and requirement management.
- Placement deletion and reminder cancellation.
- PDF document handling.
- Search filters and pagination decoding.
- Rate-limit and malformed-response handling.
- Exclusion of company-name-only Australian location matches.
- Saving discovered internship details.
- Duplicate-save prevention and missing-company fallback.
- Repository failure handling.

### Optional Live API Test

`InternshipAPILiveTests` is disabled by default because it requires a personal API key, internet access, and available request allowance.

To run it manually:

1. Complete the API configuration.
2. Temporarily replace the test’s disabled annotation with `@Test`.
3. Run only `fetchAustralianInternships()`.
4. Restore the disabled annotation before committing.

An empty result page can be valid. Passing this test confirms that returned data can be fetched and decoded; it does not verify every listing’s accuracy or external website availability.
