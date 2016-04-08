require "rails_helper"

module Notifly
  RSpec.describe Notifly::Models::Utils do
    let!(:dummy) { DummyObject.create name: 'Dummy', email: 'dummy@test.com' }
    let(:fly_options) { {template: :default, receiver: :self} }
    let!(:fly) { Notifly::Models::Options::Fly.new fly_options.merge({mail: {template: :hello}}) }

    describe '#_default_fly' do
      it "returns a Fly" do
        expect(dummy.send(:_default_fly).class).to be Notifly::Models::Options::Fly
      end
    end

    describe '#_get_attributes_from' do
      it "returns treated fly attributes" do
        expect(dummy.send(:_get_attributes_from, fly)).to eq({ template: :default, receiver: dummy, mail: :always })
      end
    end

    describe '#_create_notification_for' do
      before(:each) do
        Notifly::Notification.delete_all
        emails_sent.clear
      end
      it 'creates a notification' do
        expect{dummy.send(:_create_notification_for, fly)}.to change{Notification.count}.by(1)
      end
      context 'when notification is created successfully' do
        it 'calls after a notification' do
          # dummy.send(:_create_notification_for, fly)
          # expect(dummy).to receive(:_after_create_notification)
          pending
        end
      end
      context 'when notification could not be created' do
        it 'raises an error' do
          # expect{dummy.send(:_create_notification_for, fly)}
          pending
        end
      end
    end

    describe '#_get_mail_subject' do
      context 'when subject params is a Hash' do
        context 'with no variables' do
          context 'with no translation key given' do
            it 'returns the default key(mail template key) translation' do
              default_key = template = :default
              expect(dummy.send(:_get_mail_subject, default_key, {})).to eq('You have a new notification!')
            end
          end
          context 'with a translation key given' do
            it 'returns the given key translation' do
              default_key = template = :default
              subject = { key: :hello }
              expect(dummy.send(:_get_mail_subject, default_key, subject)).to eq('Hello!')
            end
          end
        end
        context 'with variables' do
          context 'with a subject key given' do
            it 'returns the given key interpoled translation' do
              subject = { key: :another_test_template, variables: { name: "Your Name", foo: "See You", buzz: " Later!" } }
              expect(dummy.send(:_get_mail_subject, :default, subject)).to eq('Your Name, you have a new another template notification! See You Later!')
            end
          end
        end
      end
      context 'when subject params is not a Hash ' do
        it 'returns the param as subject' do
          subject = "It's a mail subject"
        end
      end
    end

    describe '#_after_create_notification' do
      before(:each) do
        Notifly::Notification.delete_all
        emails_sent.clear
      end
      context 'when then block is present' do
        context 'with the notification param' do
          it 'runs the block code' do
            proc = ->(notification){ notification.receiver.name = "Then Affleck" }
            then_fly = Notifly::Models::Options::Fly.new(fly_options.merge({then: proc }))
            notification = Notifly::Notification.create dummy.send(:_get_attributes_from, then_fly)
            dummy.send(:_after_create_notification, notification,  then_fly)
            expect(dummy.name).to eq "Then Affleck"
          end
        end
        context 'without a param' do
          it 'runs the block code' do
            # proc = ->{ puts "Then Affleck" }
            # then_fly = Notifly::Models::Options::Fly.new(fly_options.merge({then: proc }))
            # notification = Notifly::Notification.create dummy.send(:_get_attributes_from, then_fly)
            # dummy.send(:_after_create_notification, notification,  then_fly)
            pending
          end
        end
      end
      context 'when mail settings is present' do
        it "sends a mail" do
          mail_fly = Notifly::Models::Options::Fly.new(fly_options.merge({mail: {template: :hello}}))
          notification = Notifly::Notification.create dummy.send(:_get_attributes_from, mail_fly)
          expect{dummy.send(:_after_create_notification, notification,  mail_fly)}.to change(emails_sent, :size).by(1)
        end
      end
    end

  end
end
