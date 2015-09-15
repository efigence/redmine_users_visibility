module RedmineUsersVisibility
  module Patches
    module RolePatch

      Role::USERS_VISIBILITY_OPTIONS = [
        ['all', :label_users_visibility_all],
        ['all_users', :label_users_visibility_all_users],
        ['members_of_visible_projects', :label_users_visibility_members_of_visible_projects]
      ]

      def self.included(base)
        base.class_eval do
          unloadable

          # validates_inclusion_of :users_visibility,
          #   :in => Role::USERS_VISIBILITY_OPTIONS.collect(&:first),
          #   :if => lambda {|role| role.respond_to?(:users_visibility) && role.users_visibility_changed?}

        end
      end
    end
  end
end

unless Role.included_modules.include?(RedmineUsersVisibility::Patches::RolePatch)
  Role.send(:include, RedmineUsersVisibility::Patches::RolePatch)
end
