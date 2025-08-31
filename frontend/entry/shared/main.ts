import 'virtual:uno.css'
import '@entry/shared/core.css'
import {createApp, type App} from "vue";
import Application from "@app/app/Application.vue";
import { createRouter } from "@app/app/pages/routes";

export function CoreMain(app: App<Element>): void
{
  const router = createRouter();
  app.use(router);
}

export function AppMain(): App<Element>
{
  const app = createApp(Application)
  CoreMain(app)

  return app
}
