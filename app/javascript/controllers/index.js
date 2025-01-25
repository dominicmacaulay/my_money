// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import ConditionalInputController from "./conditional_input_controller"
application.register("conditional-input", ConditionalInputController)

import DateInputController from "./date_input_controller"
application.register("date-input", DateInputController)

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import MoneyInputController from "./money_input_controller"
application.register("money-input", MoneyInputController)

import ToggleController from "./toggle_controller"
application.register("toggle", ToggleController)
