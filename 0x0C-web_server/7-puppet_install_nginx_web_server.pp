# File: nginx_setup.pp

# Install Nginx package
package { 'nginx':
  ensure => installed,
}

# Set up Nginx configuration
file { '/etc/nginx/sites-available/default':
  ensure  => present,
  content => "# Nginx configuration managed by Puppet\n
              server {
                listen 80;
                server_name _;

                location /redirect_me {
                  return 301 http://example.com/another_page;
                }

                location / {
                  add_header Cache-Control 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
                  if (\$uri ~* \\.(ico|css|js|gif|jpe?g|png)\$) {
                      expires 30d;
                      access_log off;
                  }
                  return 200 'Hello World!';
                }
              }\n",
  require => Package['nginx'],
}

# Enable the site by creating a symbolic link
file { '/etc/nginx/sites-enabled/default':
  ensure => link,
  target => '/etc/nginx/sites-available/default',
  require => File['/etc/nginx/sites-available/default'],
}

# Restart Nginx after changing the configuration
service { 'nginx':
  ensure => running,
  enable => true,
  require => File['/etc/nginx/sites-enabled/default'],
}
