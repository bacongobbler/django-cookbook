default.django.username = "django"
default.django.group = "django"
default.django.home_dir = "/home/django"
default.django.deploy_dir = "/home/django/app"
default.django.log_dir = "/var/log/django"
default.django.log_level = "debug"

# application settings
default.django.debug = 'False'
default.django.bind_address = '0.0.0.0'
default.django.worker_port = 8000
default.django.num_workers = 4

# where do we find the application?
default.django.app.git_url = "git://github.com/bacongobbler/django-heroku-example.git"
default.django.app.git_commit = "4974e8b2615068e3f30bc68074f24ea0669698f0"

# database settings
default.django.database.name = 'django'
default.django.database.user = 'django'
default.django.database.password = 'django'

# nginx config
default.django.nginx.server_root = default.django.deploy_dir
default.django.nginx.http_port = 80

# grant django user sudo access
default['authorization']['sudo']['users'] = [default.django.username]

# postgresql config
default['postgresql']['pg_hba'] = [
  {
    :type => 'local',
    :db => 'all',
    :user => default.django.database.user,
    :addr => nil,
    :method => 'ident'
  }
]
default['postgresql']['password']['postgres'] = default.django.database.password
