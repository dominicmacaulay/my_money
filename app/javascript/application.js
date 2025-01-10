// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import './initializers/honeybadger'

// Shoelace
import '@shoelace-style/shoelace/dist/themes/light.css'; // Import the theme
import '@shoelace-style/shoelace/dist/components/dropdown/dropdown.js'; // Dropdown component
import '@shoelace-style/shoelace/dist/components/menu/menu.js'; // Menu component
import '@shoelace-style/shoelace/dist/components/menu-item/menu-item.js'; // Menu-item component
import { setBasePath } from '@shoelace-style/shoelace/dist/utilities/base-path.js';

// Set the base path to the folder you copied Shoelace's assets to
setBasePath('/node_modules/@shoelace-style/shoelace/dist');
