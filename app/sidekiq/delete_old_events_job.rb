class DeleteOldEventsJob
  include Sidekiq::Job
  sidekiq_options queue: :maintenance, retry: 2

  def perform
    puts "Started Delete Job"
    ClickHouse.connection.execute <<~SQL
      ALTER TABLE default.collection_events
      DELETE WHERE event_timestamp < now() - INTERVAL 24 HOUR
    SQL

    puts "Finished Delete Job"
  rescue => e
    Rails.logger.error("ClickHouse delete failed: #{e.message}")
    raise e
  end
end
