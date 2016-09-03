rm -rf _site/
docker pull csainty/blog
docker run --rm -v $(pwd):/src -e JEKYLL_ENV=production csainty/blog jekyll build -s /src -d /src/_site
cd _site/
git init
git add .
git commit -m "Site Updated"
git remote add origin git@github.com:csainty/csainty.github.io.git
git push origin master --force
