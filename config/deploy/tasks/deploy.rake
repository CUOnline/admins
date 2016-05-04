namespace :deploy do
  task :config do
    on roles(:all) do
      if !test('[ -f /etc/wolf_core.yml ]')
        warn "**** Missing core config file /etc/wolf_core.yml ****"
      end

      within File.join(current_path, 'config', 'etc') do
        execute :sudo, :cp, '-n', 'httpd/conf.d/admins.conf', '/etc/httpd/conf.d/admins.conf'
        execute :sudo, :cp, '-n', 'odbc.ini', '/etc/odbc.ini'
        execute :sudo, :cp, '-n', 'odbcinst.ini', '/etc/odbcinst.ini'
        execute :sudo, :cp, '-n', 'amazon.redshiftodbc.ini', '/etc/amazon.redshift.ini'
      end
    end
  end

  task :restart do
    on roles(:all) do
      execute :sudo, :apachectl, :restart
    end
  end

  after :finished, :config
  after :config, :restart
end
