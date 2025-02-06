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

require 'redmine'

Redmine::Plugin.register :redmine_local_avatars do
  name 'Redmine Local Avatars plugin'
  author 'Andrew Chaika and Luca Pireddu'
  description 'This plugin lets users upload avatars directly into Redmine'
  version '1.0.5.3.0'
end

def init()
  avatars_helper = ApplicationHelper.method_defined?(:avatar) ?
                     ApplicationHelper : AvatarsHelper

  AccountController.send(:include, LocalAvatarsPlugin::AccountControllerPatch)
  avatars_helper.send(:include, LocalAvatarsPlugin::ApplicationHelperAvatarPatch)
  MyController.send(:include, LocalAvatarsPlugin::MyControllerPatch)
  User.send(:include, LocalAvatarsPlugin::UsersAvatarPatch)
  UsersController.send(:include, LocalAvatarsPlugin::UsersControllerPatch)
  UsersHelper.send(:include, LocalAvatarsPlugin::UsersHelperAvatarPatch)
end

if Rails.version > '6.0'
  init()
  return
end

receiver = Object.const_defined?('ActiveSupport::Reloader') ?  ActiveSupport::Reloader : ActionDispatch::Callbacks
receiver.to_prepare  do
	require_dependency 'project'
	require_dependency 'principal'
	require_dependency 'user'

	init()
end

require 'local_avatars_plugin/local_avatars'

# patches to Redmine
require "local_avatars_plugin/account_controller_patch.rb"
require "local_avatars_plugin/application_helper_avatar_patch.rb"
require "local_avatars_plugin/my_controller_patch.rb"
require "local_avatars_plugin/users_avatar_patch.rb"   # User model
require "local_avatars_plugin/users_controller_patch.rb"
require "local_avatars_plugin/users_helper_avatar_patch.rb"  # UsersHelper

# hooks
require 'redmine_local_avatars/hooks'
