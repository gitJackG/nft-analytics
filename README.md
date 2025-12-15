# NFT Analytics Dashboard

A simple Rails app to display top NFT collections and their NFTs. My aim with this project is to learn Rails, Sidekiq and ClickHouse.

## Features
- View collection metadata and images
- Display NFTs in each collection
- Background jobs with Sidekiq for fetching/updating data
- Display collection and nft analytics with ClickHouse
- Dynamic analytics table and chart to view nft events in real-time

## TODO
- Update what analytics to show
- Update UI
- Add jobs for other type of data (nft metada?)
- Dockerize for easier use
- OpenSea API limit? 1 hour too long? Some collections take too long to fetch?
- Create multiple jobs so no collection has to wait?

## Technologies
- Ruby on Rails
- Sidekiq
- SQLite / ClickHouse (for analytics)
- OpenSea API

## Setup
1. Clone the repo  
   ```bash
   git clone https://github.com/gitJackG/nft-analytics.git

2. Make sure you have redis and clickhouse installed localy or install and start them:
   ```bash
   sudo apt-get install lsb-release curl gpg
   curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
   sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
   sudo apt-get update
   sudo apt-get install redis
   sudo systemctl enable redis-server
   sudo systemctl start redis-server

   sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
   curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg
   ARCH=$(dpkg --print-architecture)
   echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=${ARCH}] https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
   sudo apt-get update
   sudo apt-get install -y clickhouse-server clickhouse-client
   sudo service clickhouse-server start
   CREATE DATABASE nft_analytics
   USE default
   CREATE TABLE collection_events (     event_timestamp   DateTime,     event_date        Date MATERIALIZED toDate(event_timestamp),     event_type        String,     collection_slug   String,     contract_address  String,     token_id          String DEFAULT '',     price             Float64 DEFAULT 0,     payment_symbol    String,     payment_token     String,     maker             String,     taker             String,     order_type        String DEFAULT '',     raw_quantity      UInt64 DEFAULT 1 ) ENGINE = ReplacingMergeTree ORDER BY (collection_slug, event_timestamp);

3. Install dependencies
   ```bash
    bundle install

4. Set your OpenSea API key in credentials.yml.enc
   ```bash
    EDITOR="code --wait" bin/rails credentials:edit
    opensea_api_key: "your_opensea_api_key"

5. Setup the database
   ```bash
    rails db:create db:migrate

6. Start Sidekiq
   ```bash
    bundle exec sidekiq

7. Start the Rails server
   ```bash
    rails server

8. Run 2 sidekiq jobs to fetch the collections and nfts
   ```bash
    rails console
    OpenseaCollectionsJob.perform_async
    GetNftsFromCollectionJob.perform_async

9. Visit http://localhost:3000 to see the dashboard

10. Update the cron timing in config/schedule.yml to change how often the information is updated.