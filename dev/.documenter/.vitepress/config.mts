import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import mathjax3 from "markdown-it-mathjax3";
import footnote from "markdown-it-footnote";
import path from 'path'

function getBaseRepository(base: string): string {
  if (!base || base === '/') return '/';
  const parts = base.split('/').filter(Boolean);
  return parts.length > 0 ? `/${parts[0]}/` : '/';
}

const baseTemp = {
  base: '/BioTutorials/dev/',// TODO: replace this in makedocs!
}

const navTemp = {
  nav: [
{ text: 'Rosalind.info', collapsed: false, items: [
{ text: '🧑‍🔬 Getting Started with Rosalind.info Problems', link: '/rosalind/index' },
{ text: '🧬 Problem 1: Counting DNA nucleotides', link: '/rosalind/01-dna' },
{ text: '✍️ Problem 2: Transcription', link: '/rosalind/02-rna' },
{ text: '😉 Problem 3 - Getting the complement', link: '/rosalind/03-revc' },
{ text: '♻️ 🐇 Rabbits and Recurrence Relations', link: '/rosalind/04-fib' },
{ text: '🧮 Computing GC content', link: '/rosalind/05-gc' }]
 }
]
,
}

const nav = [
  ...navTemp.nav,
  {
    component: 'VersionPicker'
  }
]

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/BioTutorials/dev/',// TODO: replace this in makedocs!
  title: 'BioTutorials',
  description: 'Documentation for BioTutorials',
  lastUpdated: true,
  cleanUrls: true,
  outDir: '../1', // This is required for MarkdownVitepress to work correctly...
  head: [
    
    ['script', {src: `${getBaseRepository(baseTemp.base)}versions.js`}],
    // ['script', {src: '/versions.js'], for custom domains, I guess if deploy_url is available.
    ['script', {src: `${baseTemp.base}siteinfo.js`}]
  ],
  
  vite: {
    define: {
      __DEPLOY_ABSPATH__: JSON.stringify('/BioTutorials'),
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, '../components')
      }
    },
    optimizeDeps: {
      exclude: [ 
        '@nolebase/vitepress-plugin-enhanced-readabilities/client',
        'vitepress',
        '@nolebase/ui',
      ], 
    }, 
    ssr: { 
      noExternal: [ 
        // If there are other packages that need to be processed by Vite, you can add them here.
        '@nolebase/vitepress-plugin-enhanced-readabilities',
        '@nolebase/ui',
      ], 
    },
  },
  markdown: {
    math: true,
    config(md) {
      md.use(tabsMarkdownPlugin),
      md.use(mathjax3),
      md.use(footnote)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"}
  },
  themeConfig: {
    outline: 'deep',
    
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },
    nav,
    sidebar: [
{ text: 'Rosalind.info', collapsed: false, items: [
{ text: '🧑‍🔬 Getting Started with Rosalind.info Problems', link: '/rosalind/index' },
{ text: '🧬 Problem 1: Counting DNA nucleotides', link: '/rosalind/01-dna' },
{ text: '✍️ Problem 2: Transcription', link: '/rosalind/02-rna' },
{ text: '😉 Problem 3 - Getting the complement', link: '/rosalind/03-revc' },
{ text: '♻️ 🐇 Rabbits and Recurrence Relations', link: '/rosalind/04-fib' },
{ text: '🧮 Computing GC content', link: '/rosalind/05-gc' }]
 }
]
,
    editLink: { pattern: "https://https://github.com/BioJulia/BioTutorials/edit/main/docs/src/:path" },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/BioJulia/BioTutorials' }
    ],
    footer: {
      message: 'Made with <a href="https://luxdl.github.io/DocumenterVitepress.jl/dev/" target="_blank"><strong>DocumenterVitepress.jl</strong></a><br>',
      copyright: `© Copyright ${new Date().getUTCFullYear()}.`
    }
  }
})
