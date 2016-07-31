module Notifly
  class NotificationMailer < ActionMailer::Base
    default from: Notifly.mailer_sender

    def notifly(to: nil, notification_id: nil, template: nil, subject: nil)
      send_notification(to, notification_id, template, subject)
    end

    private
      def send_notification(to, notification_id, template, subject)
        @notification = Notifly::Notification.find(notification_id)
        @template = template
        mail to: to, subject: subject
      end
  end
end
