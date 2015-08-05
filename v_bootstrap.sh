echo ---Updating packages---
apt-get update
#apt-get upgrade -y
apt-get install git -y

echo ---Installing RVM---
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.2
source /usr/local/rvm/scripts/rvm

echo ---Installing Jekyll---
gem install jekyll jekyll-tagging

echo ---Installing Node---
curl -sL https://deb.nodesource.com/setup_0.12 | bash -
apt-get install -y nodejs
