import { CoreMain } from '@entry/shared/main'
import { createApp } from 'vue'
import Embed from "@app/embed/Embed.vue"

const app = createApp(Embed)
CoreMain(app)
app.mount('#app')
