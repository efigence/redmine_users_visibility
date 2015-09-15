Redmine::Plugin.register :redmine_users_visibility do
  name 'Redmine Users Visibility plugin'
  author 'Maria Syczewska'
  description 'This is a plugin for Redmine for adding aditional option in User visibility (All users)'
  version '0.0.1'
  url 'https://github.com/efigence/redmine_users_visibility'
  author_url 'https://github.com/efigence'


  ActionDispatch::Callbacks.to_prepare do
      require 'redmine_users_visibility/patches/role_patch'
      require 'redmine_users_visibility/patches/principal_patch'
  end

end
