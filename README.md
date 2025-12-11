# NFT Analytics Dashboard

A simple Rails app to display top NFT collections and their NFTs.

## Features
- View collection metadata and images
- Display NFTs in each collection
- Background jobs with Sidekiq for fetching/updating data
- Display collection and nft analytics with ClickHouse 

## TODO
- Update what analytics to show
- Update UI
- Add jobs for other type of data (nft metada?)

## Technologies
- Ruby on Rails
- Sidekiq
- SQLite / ClickHouse (for analytics)
- OpenSea API

## Setup
1. Clone the repo  
   ```bash
   git clone https://github.com/gitJackG/nft-analytics.git

2. Install dependencies
   ```bash
    bundle install

3. Set your OpenSea API key in credentials.yml.enc

4. Setup the database
   ```bash
    rails db:create db:migrate

5. Start Sidekiq
   ```bash
    bundle exec sidekiq

6. Start the Rails server
   ```bash
    rails server

7. Visit http://localhost:3000 to see the dashboard


ClickHouse DataBase:

CREATE TABLE collection_events (     event_timestamp   DateTime,     event_date        Date MATERIALIZED toDate(event_timestamp),     event_type        String,     collection_slug   String,     contract_address  String,     token_id          String DEFAULT '',     price             Float64 DEFAULT 0,     payment_symbol    String,     payment_token     String,     maker             String,     taker             String,     from_address      String DEFAULT '',     to_address        String DEFAULT '',     order_type        String DEFAULT '',     trait_type        String DEFAULT '',     trait_value       String DEFAULT '',     raw_quantity      UInt64 DEFAULT 1 ) ENGINE = ReplacingMergeTree ORDER BY (collection_slug, event_timestamp);