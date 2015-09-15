module RedmineUsersVisibility
  module Patches
    module PrincipalPatch
     def self.included(base)
      base.class_eval do
        unloadable

        scope :visible, lambda {|*args|
          user = args.first || User.current

          if user.admin? || user.memberships.any? {|m| m.roles.any? {|r| r.users_visibility == 'all_users'}}
            all
          else
            view_all_active = false
            if user.memberships.to_a.any?
              view_all_active = user.memberships.any? {|m| m.roles.any? {|r| r.users_visibility == 'all'}}
            else
              view_all_active = user.builtin_role.users_visibility == 'all'
            end

            if view_all_active
              active
            else
              # self and members of visible projects
              active.where("#{table_name}.id = ? OR #{table_name}.id IN (SELECT user_id FROM #{Member.table_name} WHERE project_id IN (?))",
                user.id, user.visible_project_ids
              )
            end
          end
        }
        end
      end
    end
  end
end

unless Principal.included_modules.include?(RedmineUsersVisibility::Patches::PrincipalPatch)
  Principal.send(:include, RedmineUsersVisibility::Patches::PrincipalPatch)
end
