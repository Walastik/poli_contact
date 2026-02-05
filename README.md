# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

  Copy `.env.example` to `.env` and set `GOOGLE_CIVIC_API_KEY` for the Google Civic Information API. Optionally set `CONGRESS_DATA_PATH` if you run [unitedstates/congress](https://github.com/unitedstates/congress) and want to import bill data from a custom directory. The app loads `.env` in development and test via [dotenv-rails](https://github.com/bkeepers/dotenv).

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
