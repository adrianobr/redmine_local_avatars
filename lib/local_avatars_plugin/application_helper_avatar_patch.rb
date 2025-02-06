# Redmine Local Avatars plugin
#
# Copyright (C) 2010  Andrew Chaika, Luca Pireddu
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.expand_path('local_avatars', __dir__)

module LocalAvatarsPlugin
  module ApplicationHelperAvatarPatch
    include GravatarHelper::PublicMethods

    def self.included(base) # :nodoc:    
      base.class_eval do
        alias_method :avatar_without_local, :avatar
        alias_method :avatar, :avatar_with_local
      end
    end

    def avatar_with_local(user, options = {})
      o = options.merge(class: 'gravatar')

      if o[:size]
        # Convert type because :size is passed as not string but integer
        # in method html_subject_content (lib/redmine/helpers/gantt.rb).
        size = o[:size].is_a?(Integer) ? o[:size].to_s : o[:size]
        o[:size] = size
      else
        size = GravatarHelper::DEFAULT_OPTIONS[:size].to_s
      end

      av = user.is_a?(User) ?
             user.attachments.find_by_description('avatar') : nil

      if av
        url = url_for only_path: true, controller: 'account',
                      action: 'get_avatar', id: user
      else
        avtr = avatar_without_local(user, o)

        return avtr if avtr.present?

        url = 'default.png'
        o[:plugin] = 'redmine_local_avatars'
      end

      image_tag url, o.except(:size).merge(width: size, height: size)
    end
  end
end
