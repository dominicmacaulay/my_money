// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"

import MoneyInputController from "./money_input_controller"

application.register('money-input', MoneyInputController)
