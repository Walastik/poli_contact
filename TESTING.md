# Testing Guide

## Prerequisites

1. **PostgreSQL is running** on your machine
2. **API key is set** in `.env` file (`GOOGLE_CIVIC_API_KEY=your_key_here`)

## Step-by-Step Testing

### 1. Create and migrate the database

```bash
# Create the database
bin/rails db:create

# Run migrations to set up the schema
bin/rails db:migrate
```

### 2. (Optional) Import Congress bill data

If you have the `unitedstates/congress` data directory set up:

```bash
# Import bills from the default path (./congress-data)
bin/rails congress:import:bills

# Or specify a custom path
bin/rails congress:import:bills[/path/to/congress-data]
```

**Note:** You can skip this step for initial testing - the app will work without bill data, it just won't show any bills in the UI.

### 3. Start the Rails server

```bash
bin/rails server
# or
bin/rails s
```

The server will start on `http://localhost:3000` by default.

### 4. Test the address lookup

1. Open `http://localhost:3000` in your browser
2. Enter a US residential address (e.g., "1600 Pennsylvania Avenue NW, Washington, DC 20500")
3. Click "Lookup representatives"
4. You should see:
   - A list of current representatives for that address
   - Recent bills (if you imported Congress data)

### 5. Test via Rake task (alternative)

You can also test the Google Civic API integration directly via Rake:

```bash
bin/rails civic:import_reps_for_address["1600 Pennsylvania Avenue NW, Washington, DC 20500"]
```

This will import divisions, offices, and representatives into your database without starting the web server.

## Troubleshooting

- **Database connection error**: Make sure PostgreSQL is running (`pg_isready` or check your PostgreSQL service)
- **API key error**: Verify `.env` exists and contains `GOOGLE_CIVIC_API_KEY=...` (no quotes needed)
- **No representatives shown**: Check the Rails logs for API errors. The Google Civic API requires valid US addresses.
