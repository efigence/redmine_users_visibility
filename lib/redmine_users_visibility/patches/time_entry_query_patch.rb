module RedmineUsersVisibility
  module Patches
    module TimeEntryQueryPatch
     def self.included(base)
      base.class_eval do
        unloadable

       def initialize_available_filters
          add_available_filter "spent_on", :type => :date_past

          principals = []
          if project
            principals += project.principals.visible.sort
            unless project.leaf?
              subprojects = project.descendants.visible.to_a
              if subprojects.any?
                add_available_filter "subproject_id",
                  :type => :list_subprojects,
                  :values => subprojects.collect{|s| [s.name, s.id.to_s] }
                principals += Principal.member_of(subprojects).visible
              end
            end
          else
            if all_projects.any?
              # members of visible projects
              principals += Principal.member_of(all_projects).visible
              # project filter
              project_values = []
              if User.current.logged? && User.current.memberships.any?
                project_values << ["<< #{l(:label_my_projects).downcase} >>", "mine"]
              end
              project_values += all_projects_values
              add_available_filter("project_id",
                :type => :list, :values => project_values
              ) unless project_values.empty?
            end
          end
          principals.uniq!
          principals.sort!
          users = principals.select {|p| p.is_a?(User)}

          users_values = []
          users_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
          users_values += users.collect{|s| [s.name, s.id.to_s] }
          add_available_filter("user_id",
            :type => :list_optional, :values => users_values
          ) unless users_values.empty?

          # if for users_visibility
          if User.current.allowed_to?(:view_locked_users_entries, project, global: !project) || User.current.memberships
              .where(project_id: project.id).any? {|m| m.roles.any? {|r| r.users_visibility == 'members_with_locked'}}
            locked = []
            if project
              locked += project.locked_principals.sort
              unless project.leaf?
                subprojects = project.descendants.visible.to_a
                if subprojects.any?
                  locked += Principal.locked_member_of(subprojects)
                end
              end
            else
              if all_projects.any?
                locked += Principal.locked_member_of(all_projects)
              end
            end

            locked.uniq!
            locked.sort!
            locked_users = locked.select {|p| p.is_a?(User)}
            locked_users_values = locked_users.collect{|s| [s.name, s.id.to_s] }

            add_available_filter("locked_user_id",
              :type => :list_optional, :values => locked_users_values
            ) unless locked_users_values.empty?
          end

          activities = (project ? project.activities : TimeEntryActivity.shared.active)
          add_available_filter("activity_id",
            :type => :list, :values => activities.map {|a| [a.name, a.id.to_s]}
          ) unless activities.empty?

          add_available_filter "comments", :type => :text
          add_available_filter "hours", :type => :float

          add_custom_fields_filters(TimeEntryCustomField)
          add_associations_custom_fields_filters :project, :issue, :user
        end


        end
      end
    end
  end
end

unless TimeEntryQuery.included_modules.include?(RedmineUsersVisibility::Patches::TimeEntryQueryPatch)
  TimeEntryQuery.send(:include, RedmineUsersVisibility::Patches::TimeEntryQueryPatch)
end
