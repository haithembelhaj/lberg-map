[![Build Status](https://travis-ci.org/magdalena19/lberg-map.svg?branch=master)](https://travis-ci.org/magdalena19/lberg-map)

***Local Development Environment***

Some Dependencies you need:

    clone the repository

    get the common ruby version e.g. 2.1 at the moment (installation via RVM recommended or according to this post: ryanbigg.com/2014/10/ubuntu-ruby-ruby-install-chruby-and-you// )

    get PostgreSQL 9.3 or a later version

Inside the project folder run:

```
sudo gem install bundler

bundle install

createdb lberg-map_development

bin/rake db:migrate RAILS_ENV=development
```

Start the App with

`rails s`

You can access the site in the browser with 127.0.0.1:3000

or

`localhost:3000`

***Dev admin access***

You can enter the admin area with the credentials:
User: admin
pass: secret

## Importing and exporting locale files from CSV

People shall help us translate the interface and we don't wanna give them plain yml-files (don't we?). Hence, merge everything into a csv-file, which the load into their excel/libreoffice/whatever, and update our locale_files accordingly afterwards. Nothing fancy...

#### Export
For export to CSV call: `bundle exec rake locale_files_to_csv`

**parameters**

* `search_pattern`: identify shape of locale file names to export from
* `locale_folder`: path to locale folder

#### Import
For import from CSV call: `bundle exec rake csv_to_locale_files "./config/locales/locales_table.csv" "./config/locales/" custom en fr`

**parameters**

* `import_from_path:`: path to CSV file
* `locale_folder:`: path to locale folder
* `filename_pattern:`: identify shape of locale file names to update to
* `languages:`: specify which locales to update from CSV

#### Todos
- [ ] Check what happens on missing or wrong parameter input
