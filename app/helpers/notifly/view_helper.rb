module Notifly
  module ViewHelper
    def notiflies
      notiflies_for current_user
    end

    def notiflies_for(receiver)
      render partial: 'notifly/layouts/notifly', locals: { receiver: receiver }
    end

    def notifly_icon(have_notifications=false)
      icon = have_notifications ? Notifly.icon : Notifly.icon_empty
      if Notifly.icon_type == 'font-awesome'
        size = Notifly.icon_size
        fa_icon "#{icon} #{size}", id: 'notifly-icon'
      else
        content_tag :i, class: icon, id: 'notifly-icon'
      end
    end
  end
end
