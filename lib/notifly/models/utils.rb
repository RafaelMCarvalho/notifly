require_relative 'options/fly'

module Notifly
  module Models
    module Utils
      extend ActiveSupport::Concern

      def _create_notification_for(fly)
        new_fly = _default_fly.merge(fly)
        notification = Notifly::Notification.create _get_attributes_from(new_fly)
        _after_create_notification(notification, new_fly) if notification.persisted?

      rescue => e
        logger.error "Something goes wrong with Notifly, will ignore: #{e}"
        raise e if not Rails.env.production?

      end

      private
        def _default_fly
          self.class.default_fly || Notifly::Models::Options::Fly.new
        end

        def _get_attributes_from(fly)
          evaluated_attributes = {}
          fly.attributes.each do |key, value|
            evaluated_attributes[key] = _eval_for(key, value)
          end
          evaluated_attributes
        end

        def _eval_for(key, value)
          if [:template, :mail, :kind].include?(key.to_sym) || value.is_a?(ActiveRecord::Base)
            value
          elsif value == :self
            self
          else
            if value.is_a? Proc
              instance_exec &value
            else
              send(value)
            end
          end
        end

        def _after_create_notification(notification, fly)
          if fly.then.present?
            block = fly.then;
            block.parameters.present? ? instance_exec(notification, &block) : instance_exec(&block)
          end

          if fly.mail.present?
            template = fly.mail.try(:[], :template) || notification.template
            subject = fly.mail.try(:[], :subject) || {}
            to = fly.receiver.is_a?(Symbol) ? instance_eval(fly.receiver.to_s).try(:email) : fly.receiver.try(:email)

            mail_instance = Notifly::NotificationMailer.notifly(
              to:              to,
              template:        template,
              notification_id: notification.id,
              subject:         _get_mail_subject(template, subject)
            )

            if defined? Sidekiq::Worker
              mail_instance.deliver_later
            elsif defined? Delayed::Job
              delay.mail_instance
            else
              mail_instance.deliver
            end
          end
        end

        def _get_mail_subject(default_key, fly_mail_subject)
          subject = fly_mail_subject.dup
          if subject.is_a? Hash
            subject[:key] ||= default_key
            if subject[:variables].is_a? Hash
              subject[:variables] = subject[:variables].each{ |k, v| subject[:variables][k] = self.try(v) || v.to_s}
            end
            I18n.t("notifly.mail_subject.#{ subject[:key] }", subject[:variables])
          else
            subject.to_s
          end
        end

    end
  end
end
