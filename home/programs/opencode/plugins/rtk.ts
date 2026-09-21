// RTK OpenCode V2 plugin — rewrites shell commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.
//
// Loaded by discovery from ~/.config/opencode/plugins/. V2 local plugins
// default-export a definition with `id` and `setup`; no import from
// @opencode/plugin is used so the file has no node_modules dependency.

import { execFile } from "node:child_process"
import { promisify } from "node:util"

const execFileAsync = promisify(execFile)

type ShellCreateBefore = {
  command: string
  cwd: string
  timeout: number
  shell: string
  env: Record<string, string | undefined>
}

type PluginContext = {
  shell: {
    hook(
      name: "create.before",
      callback: (event: ShellCreateBefore) => Promise<void> | void,
    ): Promise<unknown>
  }
}

async function rewrite(command: string): Promise<string | undefined> {
  try {
    const { stdout } = await execFileAsync("rtk", ["rewrite", command], { timeout: 2000 })
    const rewritten = stdout.trim()
    return rewritten && rewritten !== command ? rewritten : undefined
  } catch {
    // rtk rewrite failed or has no equivalent — pass through unchanged.
    return undefined
  }
}

export default {
  id: "rtk",
  async setup(ctx: PluginContext) {
    try {
      await execFileAsync("rtk", ["--version"])
    } catch {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.shell.hook("create.before", async (event) => {
      const rewritten = await rewrite(event.command)
      if (rewritten) event.command = rewritten
    })
  },
}
