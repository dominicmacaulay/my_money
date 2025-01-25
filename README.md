# Overview
## Name and aliases
The project is named "MyMoney".

## Purpose
The system is designed to help Sole Proprieter, single employee business owners manage and track their incomes and expenses. Effective use of this tool with allow the business owner to cut out the unnecessary accounting fees and services they may otherwise pay for.

## Technologies
### Chosen
* Ruby on Rails
* Postgres
* puma
* Node.js
* wepack
* yarn via corepack
* Pundit

### Tried and rejected
* Mongo - Needed to use a relational database for reporting.
* Websphere - Cost
* webrick - Application servers are using newer technology now.

# How to set up the project
## External tool installation
\```
brew update --system
brew upgrade ruby-build
git clone https://github.com/dominicmacaulay/my_money.git
cd my_money
rbenv install
gem install bundler
bundle install
corepack enable
yarn install
\```

## How to run locally
`rails s`
&
`yarn build --watch`


## How to run tests
`rake`

## Editor plugins
* Rubocop linter

## Testing tools
RSpec is the tool used for testing

## Continuous integration
Github CI is enabled

# Branching strategy
To begin a new feature run, `git checkout -b feature/<branchname>`.
When finished with the feature and the code has been reviewed, the commits should be squashed before merging. See [RoleModel Best Practices](https://github.com/RoleModel/BestPractices) for more information.

# Links to:
## [Git repo](https://github.com/dominicmacaulay/my_money)
## [List of contributors](http://github.com/RoleModel)
## [Change log](file://./docs/change_log.md)
