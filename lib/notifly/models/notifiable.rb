require_relative 'options/fly'
require_relative 'utils'

module Notifly
  module Models
    module Notifiable
      extend ActiveSupport::Concern
      include Notifly::Models::Utils

      def notifly!(args={})
        fly = Notifly::Models::Options::Fly.new args.merge(receiver: :self)
        _create_notification_for(fly)
      end
    end
  end
end