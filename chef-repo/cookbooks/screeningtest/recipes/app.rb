# Install make so we can build the Go app
package 'make'

# Create a directory for the app to be cloned to
# Default: /opt/screeningtest
directory node['screeningtest']['app_dir'] do
  owner 'www-data'
  group 'www-data'
  mode  '0755'
end

# Clone app git repo to /opt/screeningtest
# If any new commits on master are pulled, trigger
# make to rebuild the app
git node['screeningtest']['app_dir'] do
  repository node['screeningtest']['git_repository']
  revision node['screeningtest']['git_branch']
  user 'www-data'
  group 'www-data'
  action :sync
  notifies :run, 'execute[build-app]', :immediately
end

# Build the app when required
execute 'build-app' do
  command "make build"
  environment 'PATH' => "#{ENV['PATH']}:/usr/local/go/bin"
  cwd node['screeningtest']['app_dir']
  user 'www-data'
  action :nothing
  notifies :restart, 'service[screeningtest]'
end

# Create the upstart init script
template '/etc/init/screeningtest.conf' do
  source  'upstart.conf.erb'
  owner   'root'
  group   'root'
  mode    '0644'
  notifies :restart, 'service[screeningtest]'
end

# Start and enable the service
service "screeningtest" do
   action [ :enable, :start ]
end
