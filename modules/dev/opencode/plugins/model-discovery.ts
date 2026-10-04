// OpenCode V2 plugin: discover models from OpenAI-compatible endpoints.
// The provider registry is refreshed periodically so model additions/removals
// do not require changing the Nix configuration.

declare const process: { env: Record<string, string | undefined> }

type RemoteModel = {
  id?: string
  name?: string
  context_length?: number
  context_window?: number
  supported_endpoints?: string[]
}

type ProviderModel = {
  id: string
  modelID: string
  providerID: string
  name: string
  api: {
    type: "aisdk"
    package: string
  }
  capabilities: {
    tools: boolean
    input: string[]
    output: string[]
  }
  request: {
    headers: Record<string, string>
    body: Record<string, unknown>
  }
  variants: []
  time: { released: number }
  cost: [{ input: number; output: number; cache: { read: number; write: number } }]
  status: "active"
  enabled: true
  limit: { context: number; output: number }
}

type ProviderEditor = {
  models: {
    set(providerID: string, models: ProviderModel[]): void
  }
}

type ProviderContext = {
  provider: {
    transform(callback: (editor: ProviderEditor) => void): Promise<unknown>
    reload(): Promise<void>
  }
}

const PROVIDERS = [
  {
    id: "commandcode",
    url: "https://api.commandcode.ai/provider/v1/models",
    keyEnv: "COMMANDCODE_API_KEY",
    keyHeader: "authorization",
    // Command Code's Claude models require the Anthropic Messages API.
    // Keep this provider limited to models that the OpenAI-compatible runtime
    // can actually serve.
    chatOnly: true,
  },
  {
    id: "mimo",
    url: "https://token-plan-sgp.xiaomimimo.com/v1/models",
    keyEnv: "MIMO_API_KEY",
    keyHeader: "api-key",
    chatOnly: false,
  },
] as const

const REFRESH_INTERVAL_MS = 15 * 60 * 1000
const OPENAI_COMPATIBLE = "@opencode/ai/providers/openai-compatible"

function modelFromRemote(providerID: string, remote: RemoteModel): ProviderModel | undefined {
  if (!remote.id) return undefined
  const context = remote.context_length ?? remote.context_window ?? 128_000
  return {
    id: remote.id,
    modelID: remote.id,
    providerID,
    name: remote.name ?? remote.id,
    api: { type: "aisdk", package: OPENAI_COMPATIBLE },
    capabilities: {
      tools: true,
      input: ["text", "image"],
      output: ["text"],
    },
    request: { headers: {}, body: {} },
    variants: [],
    time: { released: Date.now() },
    cost: [{ input: 0, output: 0, cache: { read: 0, write: 0 } }],
    status: "active",
    enabled: true,
    limit: { context, output: Math.min(context, 32_768) },
  }
}

async function fetchModels(provider: (typeof PROVIDERS)[number]): Promise<ProviderModel[]> {
  const headers: Record<string, string> = { accept: "application/json" }
  const key = process.env[provider.keyEnv]
  if (key) headers[provider.keyHeader] = provider.keyHeader === "authorization" ? `Bearer ${key}` : key

  const response = await fetch(provider.url, { headers, signal: AbortSignal.timeout(10_000) })
  if (!response.ok) throw new Error(`${response.status} ${response.statusText}`)

  const payload = (await response.json()) as { data?: RemoteModel[] }
  const models = payload.data ?? []
  return models
    .filter((model) => {
      // Some gateways omit supported_endpoints. In that case retain the model;
      // the provider's OpenAI-compatible runtime will determine compatibility.
      return !provider.chatOnly || !model.supported_endpoints || model.supported_endpoints.includes("/chat/completions")
    })
    .map((model) => modelFromRemote(provider.id, model))
    .filter((model): model is ProviderModel => model !== undefined)
}

export default {
  id: "model-discovery",
  async setup(ctx: ProviderContext) {
    let disposed = false
    const discovered = new Map<string, ProviderModel[]>()

    // Keep one transform for the lifetime of the plugin. The callback
    // captures `discovered`; refreshes update that map and replay this
    // transform via provider.reload(). Adding a new transform on every
    // refresh leaves stale registrations behind.
    const refresh = async (reload = true) => {
      let changed = false
      for (const provider of PROVIDERS) {
        try {
          const models = await fetchModels(provider)
          discovered.set(provider.id, models)
          changed = true
          console.info(`[model-discovery] ${provider.id}: loaded ${models.length} models`)
        } catch (error) {
          // Keep the last successful inventory instead of replacing it with an
          // empty list when a provider is temporarily unavailable.
          console.warn(`[model-discovery] ${provider.id}: unable to refresh models`, error)
        }
      }
      if (changed && reload) await ctx.provider.reload()
    }

    // Populate the source before registering the transform. Registering it
    // while the map is empty can leave an empty inventory on older V2 builds.
    await refresh(false)
    await ctx.provider.transform((editor) => {
      for (const provider of PROVIDERS) {
        const models = discovered.get(provider.id)
        if (models) editor.models.set(provider.id, models)
      }
    })

    const timer = setInterval(() => {
      if (!disposed) void refresh().catch((error) => console.warn("[model-discovery] refresh failed", error))
    }, REFRESH_INTERVAL_MS)

    return () => {
      disposed = true
      clearInterval(timer)
    }
  },
}
