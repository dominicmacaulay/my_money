// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import './initializers/honeybadger'

// Shoelace
import { registerIconLibrary } from "@shoelace-style/shoelace/dist/utilities/icon-library";
registerIconLibrary('system', {resolver: (_name) => ''}) // No Icons needed for this project

import '@shoelace-style/shoelace/dist/components/dropdown/dropdown'; // Dropdown component
import '@shoelace-style/shoelace/dist/components/menu/menu'; // Menu component
import '@shoelace-style/shoelace/dist/components/menu-item/menu-item'; // Menu-item component
