# Redmine Users Visibility plugin

#### Plugin which adds additional users visibility (Members of visible projects with locked) option in Roles.

## Requirements

Developed and tested on Redmine 3.1.0.

## Installation

1. Go to your Redmine installation's plugins/directory.
2. `git clone https://github.com/efigence/redmine_users_visibility`
3. Go back to root directory.
4. `rake redmine:plugins:migrate RAILS_ENV=production`
5. Restart Redmine.

## Usage

Plugin introduces a third option in Role's users visibility - Members of visible projects with locked. Roles with this option assigned can filter issues assigned to locked
users, as well as generate time entry reports for locked users.

## License

    Redmine Users Visibility plugin
    Copyright (C) 2015 efigence S.A.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
