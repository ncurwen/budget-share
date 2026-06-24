// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import '../components'
import TC from "@rolemodel/turbo-confirm"

TC.start()
Turbo.config.drive.progressBarDelay = 250;

// idiomorph updates the checked attribute but not the property during morphs
new MutationObserver(mutations => {
  mutations.forEach(({ target }) => { target.checked = target.defaultChecked })
}).observe(document.body, { subtree: true, attributeFilter: ["checked"], attributes: true })
