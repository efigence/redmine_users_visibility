module RedmineUsersVisibility
  module Patches
    module IssueQueryPatch
     def self.included(base)
      base.class_eval do
        unloadable

        def initialize_available_filters
          principals = []
          subprojects = []
          versions = []
          categories = []
          issue_custom_fields = []

          if project
            principals += project.principals.visible
            unless project.leaf?
              subprojects = project.descendants.visible.to_a
              principals += Principal.member_of(subprojects).visible
            end
            versions = project.shared_versions.to_a
            categories = project.issue_categories.to_a
            issue_custom_fields = project.all_issue_custom_fields
          else
            if all_projects.any?
              principals += Principal.member_of(all_projects).visible
            end
            versions = Version.visible.where(:sharing => 'system').to_a
            issue_custom_fields = IssueCustomField.where(:is_for_all => true)
          end
          principals.uniq!
          principals.sort!
          principals.reject! {|p| p.is_a?(GroupBuiltin)}
          users = principals.select {|p| p.is_a?(User)}

          add_available_filter "status_id",
            :type => :list_status, :values => IssueStatus.sorted.collect{|s| [s.name, s.id.to_s] }

          if project.nil?
            project_values = []
            if User.current.logged? && User.current.memberships.any?
              project_values << ["<< #{l(:label_my_projects).downcase} >>", "mine"]
              project_values << ["<< #{l(:label_opened_projects).downcase} >>", "opened"]
            end
            project_values += all_projects_values
            add_available_filter("project_id",
              :type => :list, :values => project_values
            ) unless project_values.empty?
          end
          add_available_filter "parent_id", :type => :integer, :label => 'field_parent_issue'
          add_available_filter "tracker_id",
            :type => :list, :values => trackers.collect{|s| [s.name, s.id.to_s] }

          add_available_filter "priority_id",
            :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] }

          author_values = []
          author_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
          author_values += users.collect{|s| [s.name, s.id.to_s] }
          add_available_filter("author_id",
            :type => :list, :values => author_values
          ) unless author_values.empty?

          assigned_to_values = []
          assigned_to_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
          assigned_to_values += (Setting.issue_group_assignment? ?
                                    principals : users).collect{|s| [s.name, s.id.to_s] }
          # if for users_visibility
          if User.current.admin? || User.current.memberships
                                                .where(project_id: project.id).any? {|m| m.roles.any? {|r| r.users_visibility == 'members_with_locked'}}
            assigned_to_values += Principal.locked_member_of(project).collect{|s| [s.name, s.id.to_s] }
          end
          add_available_filter("assigned_to_id",
            :type => :list_optional, :values => assigned_to_values
          ) unless assigned_to_values.empty?

          group_values = Group.givable.visible.collect {|g| [g.name, g.id.to_s] }
          add_available_filter("member_of_group",
            :type => :list_optional, :values => group_values
          ) unless group_values.empty?

          role_values = Role.givable.collect {|r| [r.name, r.id.to_s] }
          add_available_filter("assigned_to_role",
            :type => :list_optional, :values => role_values
          ) unless role_values.empty?

          if versions.any?
            add_available_filter "fixed_version_id",
              :type => :list_optional,
              :values => versions.sort.collect{|s| ["#{s.project.name} - #{s.name}", s.id.to_s] }
          end

          if categories.any?
            add_available_filter "category_id",
              :type => :list_optional,
              :values => categories.collect{|s| [s.name, s.id.to_s] }
          end

          add_available_filter "status_id_was",
            :type => :list, :values => IssueStatus.sorted.collect{|s| [s.name, s.id.to_s] }
          add_available_filter "priority_id_was",
            :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] }
          add_available_filter "tracker_id_was",
            :type => :list, :values => trackers.collect{|s| [s.name, s.id.to_s] }
          add_available_filter "assigned_to_id_was",
            :type => :list, :values => assigned_to_values unless assigned_to_values.empty?

          add_available_filter "subject", :type => :text
          add_available_filter "created_on", :type => :date_past
          add_available_filter "updated_on", :type => :date_past
          add_available_filter "closed_on", :type => :date_past
          add_available_filter "start_date", :type => :date
          add_available_filter "due_date", :type => :date
          add_available_filter "estimated_hours", :type => :float
          add_available_filter "done_ratio", :type => :integer

          if User.current.allowed_to?(:set_issues_private, nil, :global => true) ||
            User.current.allowed_to?(:set_own_issues_private, nil, :global => true)
            add_available_filter "is_private",
              :type => :list,
              :values => [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]]
          end

          if User.current.logged?
            add_available_filter "watcher_id",
              :type => :list, :values => [["<< #{l(:label_me)} >>", "me"]]
          end

          if subprojects.any?
            add_available_filter "subproject_id",
              :type => :list_subprojects,
              :values => subprojects.collect{|s| [s.name, s.id.to_s] }
          end

          add_custom_fields_filters(issue_custom_fields)

          add_associations_custom_fields_filters :project, :author, :assigned_to, :fixed_version

          IssueRelation::TYPES.each do |relation_type, options|
            add_available_filter relation_type, :type => :relation, :label => options[:name]
          end

          Tracker.disabled_core_fields(trackers).each {|field|
            delete_available_filter field
          }
          end

        end
      end
    end
  end
end

unless IssueQuery.included_modules.include?(RedmineUsersVisibility::Patches::IssueQueryPatch)
  IssueQuery.send(:include, RedmineUsersVisibility::Patches::IssueQueryPatch)
end
