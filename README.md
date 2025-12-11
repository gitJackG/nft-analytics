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