import {defineConfig, type UserConfig} from 'vite'
import { resolve } from 'node:path';
import { copyFileSync } from 'node:fs';

import vue from '@vitejs/plugin-vue'
import uno from 'unocss/vite'
import { VitePWA } from 'vite-plugin-pwa'

type Target = 'app' | 'pwa' | 'embed'
export default defineConfig(({ mode }): UserConfig =>
{
  const target = (process.env['GESTALT_TARGET'] ?? 'app') as Target;
  console.log('Mode:', mode)
  console.log('Target:', target)
  const indexHtml = `entry/${target}/index.html`

  let config: UserConfig = {
    build: {},
    resolve: {
      alias: {
        '@entry': resolve(__dirname, 'entry'),
        '@app': resolve(__dirname),
      }
    },
    plugins: [
      vue(),
      uno(),
      {
        name: "index-html-replacer",
        configureServer(server) {
          server.middlewares.use(
            (req, _, next) => {
              if (req.url === '/') {
                req.url = `/${indexHtml}`;
              }
              console.log(req.url)
              next();
            }
          )
        }
      }
    ]
  }

  if (target === 'pwa')
  {
    config.plugins!.push(VitePWA())
  }
  if (target === 'app')
  {
    config.build!.target = process.env.TAURI_ENV_PLATFORM === 'windows'
      ? 'chrome105'
      : 'safari13'

    config.build!.minify = process.env.TAURI_ENV_DEBUG ? 'esbuild' : false
    config.build!.sourcemap = !!process.env.TAURI_ENV_DEBUG
  }

  copyFileSync(resolve(__dirname, indexHtml), resolve(__dirname, 'index.html'))
  return config;
})
