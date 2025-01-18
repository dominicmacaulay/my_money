// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"

import DateInputController from "./date_input_controller"
import MoneyInputController from "./money_input_controller"

application.register('date-input', DateInputController)
application.register('money-input', MoneyInputController)
