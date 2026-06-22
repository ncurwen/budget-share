// Registers Stimulus controllers used across the app.
import { application } from "./application"

import ThemeController from "./theme_controller"
application.register("theme", ThemeController)

import FlashController from "./flash_controller"
application.register("flash", FlashController)

import ModalController from "./modal_controller"
application.register("modal", ModalController)
