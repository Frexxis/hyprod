import QtQuick

QtObject {
    default property list<QtObject> data

    function buildEndpoint(model: AiModel): string { throw new Error("Not implemented") }
    function buildRequestData(model: AiModel, messages, systemPrompt: string, temperature: real, tools: list<var>, filePath: string) { throw new Error("Not implemented") }
    function buildAuthorizationHeader(apiKeyEnvVarName: string): string { throw new Error("Not implemented") }
    function parseResponseLine(line: string, message: AiMessageData) { throw new Error("Not implemented") }
    function onRequestFinished(message: AiMessageData): var { return {} } // Default: no special handling
    function reset() { } // Reset any internal state if needed
    function buildScriptFileSetup(filePath) { return "" } // Default: no setup
    function finalizeScriptContent(scriptContent: string): string { return scriptContent } // Optionally modify/finalize script

    // Direct CLI execution support (for Claude Code CLI)
    function usesDirectExecution(): bool { return false } // Override in strategies that use direct CLI
    function buildCommand(model: AiModel, messages, systemPrompt: string, temperature: real, tools: list<var>, filePath: string): list<string> { return [] }
    function supportsPtyWrapper(): bool { return false }
}
