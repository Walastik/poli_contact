## Poli Contact – Data Integration Plan

This document captures the initial plan for integrating the Google Civic Information API and the `unitedstates/congress` data into this Rails + PostgreSQL application.

### 1. Data sources and roles

- **Google Civic Information API** (`https://developers.google.com/civic-information/`):
  - Map user addresses to political geography and representatives.
  - Provide Open Civic Data (OCD) division identifiers and basic office/official metadata.
  - Used primarily at request time, with results persisted to our database for caching and joins.

- **`unitedstates/congress` project** (`https://github.com/unitedstates/congress`):
  - Provide canonical legislative data (bills, amendments, votes, etc.).
  - Operates as an external ETL producer that downloads and normalizes Congressional data into JSON/XML files under a `data/` directory.
  - Our app will import from those JSON files into Postgres.

### 2. Initial domain model (v1 scope)

- `Division`
  - Attributes: `ocd_id`, `name`, `level`, `country`, `state`, `county`, `district`.
  - Represents a political geography unit (e.g., state, congressional district) keyed by OCD ID.

- `Office`
  - Attributes: `name`, `division_id`, `role`, `google_civic_office_id`.
  - Represents an elected office within a division (e.g., U.S. Senator, U.S. Representative).

- `Person`
  - Attributes: `name`, `party`, `photo_url`, `email`, `phone`, `url`, `address_json`.
  - External IDs: `google_civic_person_id`, `bioguide_id`, `govtrack_id`, etc.
  - Canonical person entity used to join Google Civic data with Congress bill metadata.

- `OfficeHolding`
  - Attributes: `office_id`, `person_id`, `start_date`, `end_date`.
  - Join model that captures who holds which office and when.

- `Bill`
  - Attributes: `congress`, `bill_type`, `number`, `title`, `short_title`, `summary`, `introduced_on`, `current_status`, `current_status_date`, `source_path`.
  - Optionally associates to `Person` via sponsor identifiers.
  - Backed by JSON files produced by `unitedstates/congress`.

### 3. Integration patterns

- **Google Civic API**
  - Service object: `GoogleCivic::Client` (Faraday-based HTTP client).
  - Importers:
    - `GoogleCivic::DivisionImporter` – upserts `Division` records from the `divisions` section of the response.
    - `GoogleCivic::RepresentativesImporter` – upserts `Office`, `Person`, `OfficeHolding` from `offices` and `officials`.
  - Configuration:
    - API key via `ENV["GOOGLE_CIVIC_API_KEY"]` (e.g., managed in development by dotenv).

- **Congress data**
  - External process runs `usc-run govinfo --bulkdata=BILLSTATUS` and `usc-run bills` to populate a shared `data/` directory as described in the upstream README.
  - Rails initializer exposes `Rails.application.config.congress_data_path` pointing to that directory (configured via `ENV["CONGRESS_DATA_PATH"]` with a reasonable default).
  - Importer:
    - `CongressData::BillImporter` – traverses `data/**/*.json` bill files, parses them, and upserts `Bill` records keyed by `(congress, bill_type, number)`.

### 4. Rake tasks

- `civic:import_reps_for_address["123 Main St, City, ST"]`
  - Uses `GoogleCivic::Client` and importer services to hydrate `Division`, `Office`, `Person`, and `OfficeHolding` in the DB.

- `congress:import:bills[DATA_PATH]`
  - Uses `CongressData::BillImporter` to import bills from a specified data root or from the configured default.

### 5. User-facing flow (v1)

- A simple homepage allows entering a residential address.
- On submit:
  1. Call Google Civic API to retrieve representatives for the address.
  2. Import/update divisions, offices, people, and office holdings in Postgres.
  3. Query Postgres to render:
     - Current representatives for that address.
     - A small list of recent related bills (e.g., House bills for House representatives, Senate bills for Senators) from our `bills` table.
- All UI reads from the database; external APIs and JSON sources are only used for ingestion.

### 6. Next steps

1. Add supporting gems (`faraday`, `dotenv-rails`) and configuration for API keys and data paths.
2. Create core models and migrations (`Division`, `Office`, `Person`, `OfficeHolding`, `Bill`).
3. Implement the Google Civic and Congress importer services and rake tasks.
4. Build the simple address input UI and results page backed entirely by our database.

