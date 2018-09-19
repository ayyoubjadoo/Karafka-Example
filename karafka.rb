# frozen_string_literal: true

# Non Ruby on Rails setup
ENV['RACK_ENV'] ||= 'development'
ENV['KARAFKA_ENV'] ||= ENV['RACK_ENV']
Bundler.require(:default, ENV['KARAFKA_ENV'])
Karafka::Loader.load(Karafka::App.root)
require 'active_support/core_ext/hash'

# App class
# @note The whole setup and routing could be placed in a single class definition
#   but we wanted to show you, that in case of bigger applications, you can create
#   a structure similar to rails config/routes.rb, etc.
class App < Karafka::App
  setup do |config|
    # Karafka will autodiscover kafka_hosts based on Zookeeper but we need it set manually
    # to run tests without running kafka and zookeper
    config.kafka.seed_brokers = %w[kafka://kafka:9092]
    config.client_id = "example_app_01"
    # Enable those 2 lines if you use Rails and want to use hash with indifferent access for
    # Karafka params
    # require 'active_support/hash_with_indifferent_access'
    # config.params_base_class = HashWithIndifferentAccess
  end

  after_init do
    WaterDrop.setup { |config| config.deliver = !Karafka.env.test? }
  end
end

Karafka.monitor.subscribe(Karafka::Instrumentation::Listener)

# Consumer group defined with the 0.6+ routing style (recommended)
App.consumer_groups.draw do
  consumer_group :batched_group do
    batch_fetching true

    topic :xml_data do
      consumer XmlMessagesConsumer
      batch_consuming false
      parser XmlParser
    end

    topic :inline_batch_data do
      consumer InlineBatchConsumer
      batch_consuming true
    end

    topic :callbacked_data do
      consumer CallbackedConsumer
      batch_consuming true
    end
  end

  # A ping-pong implementation using karafka-sidekiq backend
  # @note The backend is totally optional, if you disable it, the game will
  # work as well
  consumer_group :async_pong do
    topic :ping do
      consumer Pong::PingConsumer
      backend :inline
    end

    topic :pong do
      consumer Pong::PongConsumer
      backend :inline
    end
  end
end

App.boot!
