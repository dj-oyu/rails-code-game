doc
├── System-spec.md
├── Module-spec.md
├── module
│   ├── problem-spec.md
│   ├── answer-spec.md
│   └── ui-spec.md
└── overview.md

# Railsプロジェクト構成

app
├── controllers
├── models
├── views
├── helpers
├── jobs
├── mailers
├── assets
│   ├── images
│   └── stylesheets
config
├── application.rb
├── boot.rb
├── environment.rb
├── environments
├── initializers
├── locales
├── puma.rb
├── routes.rb
db
├── seeds.rb
Gemfile
Rakefile
README.md

lib
├── code_evaluator.rb

spec
├── lib
│   └── code_evaluator_spec.rb

app/controllers
├── problems_controller.rb
├── answers_controller.rb

app/views/problems
├── index.html.erb
├── show.html.erb

app/views/answers
├── create.html.erb

config/routes.rb
