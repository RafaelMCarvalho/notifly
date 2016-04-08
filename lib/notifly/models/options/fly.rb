module Notifly
  module Models
    module Options
      class Fly
        attr_accessor :before, :after, :template, :sender, :receiver, :target,
          :if, :unless, :data, :mail, :kind, :then

        def initialize(options={})
          options = options.fetch(:default_values, options)
          options.each { |key, value| try "#{key}=", value }
        end

        def hook
          if @before.nil?
            :after
          else
            :before
          end
        end

        def method_name
          self.send(hook)
        end

        def attributes
          no_attrs = [hook, :if, :unless, :mail, :then]
          attrs = instance_values.reject { |key| no_attrs.include? key.to_sym  }
          attrs.deep_symbolize_keys.merge({mail: get_mail_type})
        end

        def merge(fly)
          raise TypeError, "#{fly} is not a Fly" unless fly.is_a? self.class

          Notifly::Models::Options::Fly.new instance_values.merge(fly.instance_values)
        end

        def get_mail_type
          if mail.blank? or mail == false
            :never
          elsif mail.is_a?(Hash) and mail[:only]
            :only
          elsif mail == true or mail.is_a?(Hash)
            :always
          end
        end
      end
    end
  end
end