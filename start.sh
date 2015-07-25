vagrant up
vagrant rsync-auto & vagrant ssh -c "jekyll serve -s /vagrant -d /vagrant/_site --host 0.0.0.0"
