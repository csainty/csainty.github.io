rm -rf _site/
docker run --rm -v $(pwd):/src csainty/blog jekyll build -s /src -d /src/_site
cd _site/
git init
git add .
git commit -m "Site Updated"
git remote add origin git@github.com:csainty/csainty.github.io.git
git push origin master --force
