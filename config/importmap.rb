# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.23
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.23
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @8.1.200
pin "@rolemodel/turbo-confirm", to: "@rolemodel--turbo-confirm.js" # @2.2.3
pin "autonumeric" # @4.10.9
pin "flatpickr" # @4.6.13

# Shoelace components from CDN
pin "@shoelace-style/shoelace/dist/utilities/icon-library", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.0/cdn/utilities/icon-library.js"
pin "@shoelace-style/shoelace/dist/components/dropdown/dropdown", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.0/cdn/components/dropdown/dropdown.js"
pin "@shoelace-style/shoelace/dist/components/menu/menu", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.0/cdn/components/menu/menu.js"
pin "@shoelace-style/shoelace/dist/components/menu-item/menu-item", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.0/cdn/components/menu-item/menu-item.js"
pin "@shoelace-style/shoelace/dist/components/divider/divider", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.0/cdn/components/divider/divider.js"

# Local application files
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/initializers", under: "initializers"
