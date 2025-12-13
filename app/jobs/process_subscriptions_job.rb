class ProcessSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Subscription.active.due_today.find_each do |subscription|
      subscription.process_order!
    rescue => e
      Rails.logger.error "Failed to process subscription #{subscription.id}: #{e.message}"
      # Optionally notify admin or user about failure
    end
  end
end
