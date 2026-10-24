# CampusFlow [work-in-progress]

CampusFlow helps students organise academic tasks, placement
requirements, and saved internship opportunities.

## Running locally

1. Clone the repository.
2. Open `StudyPlannerV2.xcodeproj` in Xcode.
3. Follow the API configuration steps below to enable internship discovery.
4. Select the StudyPlannerV2 scheme and an iPhone simulator.
5. Build and run with ⌘R.

## Internship API configuration

Internship discovery uses CleanJobData. Each developer supplies
their own API key for local development.

1. Create an account and obtain an API key:
   https://cleanjobdata.com/feeds/australia

2. Copy this file:

   `StudyPlannerV2/Configuration/Development.xcconfig.example`

   and name the copy:

   `StudyPlannerV2/Configuration/Development.xcconfig`

3. Replace the placeholder `YOUR_API_KEY_HERE` in your local copy:

   ```text
   CLEANJOBDATA_API_KEY = YOUR_API_KEY_HERE
   ```

4. In Xcode, confirm that the StudyPlannerV2 app target's Debug
   configuration uses `Development.xcconfig`.

5. Build and run the Debug configuration.

The real `Development.xcconfig` file is excluded from Git.
Commit only the example file with its placeholder. Do not put
real keys in Swift source files, screenshots, or commits.

The app reads the key through `Env.swift`. Missing API configuration
should affect discovery only, not access to locally saved planner data.

## API and saved internship support

- Requests Australian internships from CleanJobData.
- Supports title search, remote-only filtering, and cursor pagination.
- Decodes listing details and available application links.
- Saves selected listings through the existing saved-internship use case
  and SwiftData repository.
- Rejects repeated saves of the same provider listing.
- Preserves manual internship saving.

The Discover screen still needs to be connected to these dependencies.
Fetching a listing does not automatically save it.

Provider classifications may be inaccurate. A title search such as
“intern” produced more relevant results during manual testing.

## Testing

Run the normal test suite with ⌘U.

API-client tests use simulated responses and do not require a real key
or internet connection. Save tests use temporary in-memory storage
or mock repositories.

Coverage includes:

- Search filters, authorization headers, and pagination decoding.
- Rate-limit and malformed-response handling.
- Saving discovered listing details to SwiftData.
- Duplicate-save prevention.
- Missing company validation and repository save failures.

### Optional live API test

`InternshipAPILiveTests` is disabled by default because it requires
a personal API key, internet access, and available API request allowance.

To run it manually:

1. Complete the local API configuration.
2. Temporarily replace its disabled annotation with `@Test`.
3. Run only `fetchAustralianInternships`.
4. Restore the disabled annotation before committing.

An empty result page can be valid. The test does not guarantee that
every listing is correctly classified or that the Discover UI is connected.
