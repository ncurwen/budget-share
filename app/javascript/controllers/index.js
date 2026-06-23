// Registers Stimulus controllers used across the app.
import { application } from "./application"

import ThemeController from "./theme_controller"
application.register("theme", ThemeController)

import FlashController from "./flash_controller"
application.register("flash", FlashController)

import DialogComponentController from "../../components/dialog_component_controller"
application.register("dialog-component", DialogComponentController)

import AutoSubmit from "@stimulus-components/auto-submit"
application.register("auto-submit", AutoSubmit)

import Timeago from "@stimulus-components/timeago"
application.register("timeago", Timeago)
