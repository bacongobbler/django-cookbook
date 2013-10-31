
db_name = node.django.database.name
db_user = node.django.database.user

execute 'create-django-database' do
    user 'postgres'
    group 'postgres'
    db_exists = <<-EOF
psql -c "select * from pg_database WHERE datname='#{db_name}'" | grep -c #{db_name}
EOF
    command "createdb --encoding=latin1 --template=template0 #{db_name}"
    not_if db_exists, :user => 'postgres'
end

execute 'create-django-database-user' do
    user 'postgres'
    group 'postgres'
    user_exists = <<-EOF
psql -c "select * from pg_user where usename='#{db_user}'" | grep -c #{db_user}
EOF
    command "createuser --no-superuser --no-createrole --no-createdb --no-password #{db_user}"
    not_if user_exists, :user => 'postgres'
end
