module RedmineUsersVisibility
  module Patches
    module RolePatch

      Role::USERS_VISIBILITY_OPTIONS = [
        ['all', :label_users_visibility_all],
        ['members_with_locked', :label_members_of_visible_projects_with_locked],
        ['members_of_visible_projects', :label_users_visibility_members_of_visible_projects]
      ]

      def self.included(base)
        base.class_eval do
          unloadable

          clear_validators!

          validates_presence_of :name
          validates_uniqueness_of :name
          validates_length_of :name, :maximum => 30
          validates_inclusion_of :issues_visibility,
            :in => Role::ISSUES_VISIBILITY_OPTIONS.collect(&:first),
            :if => lambda {|role| role.respond_to?(:issues_visibility) && role.issues_visibility_changed?}
          validates_inclusion_of :users_visibility,
            :in => Role::USERS_VISIBILITY_OPTIONS.collect(&:first),
            :if => lambda {|role| role.respond_to?(:users_visibility) && role.users_visibility_changed?}

        end
      end
    end
  end
end

unless Role.included_modules.include?(RedmineUsersVisibility::Patches::RolePatch)
  Role.send(:include, RedmineUsersVisibility::Patches::RolePatch)
end
