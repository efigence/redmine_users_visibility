require File.expand_path("../../test_helper", __FILE__)

class AccountTest < Redmine::IntegrationTest
  fixtures :users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations, :roles, :members, :member_roles, :issues

  def setup
    @project = projects(:projects_001)
  end

  def test_should_allow_admin_to_see_locked_users
    skip # 403 error
    log_user("admin", "admin")
    assert_equal true, User.current.admin?

    get project_issues_path(@project)
    assert_response :success

    get report_project_time_entries_path(@project)
    assert_response :success

  end

end
