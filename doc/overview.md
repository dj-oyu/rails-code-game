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
│   ├── application_controller.rb
│   ├── problems_controller.rb
│   └── answers_controller.rb
├── models
│   ├── application_record.rb
│   ├── problem.rb
│   └── answer.rb
├── views
│   ├── layouts
│   ├── problems
│   │   ├── index.html.erb
│   │   └── show.html.erb
│   └── answers
│       └── create.html.erb
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
├── database.yml

db
├── migrate
│   └── *.rb  # マイグレーションファイル
├── schema.rb
├── seeds.rb

lib
├── code_evaluator.rb
├── problem_generator.rb

spec
├── lib
│   ├── code_evaluator_spec.rb
│   └── problem_generator_spec.rb
├── rails_helper.rb
├── spec_helper.rb

.env
Gemfile
Rakefile
README.md
