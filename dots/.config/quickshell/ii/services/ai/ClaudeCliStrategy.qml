import QtQuick
import Quickshell.Io

ApiStrategy {
    id: root

    // Claude CLI path - dynamically detected from PATH
    property string cliPath: ""

    Component.onCompleted: {
        // Find claude in PATH using 'which' command
        whichProcess.running = true;
    }

    Process {
        id: whichProcess
        command: ["which", "claude"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim();
                if (output && output.length > 0 && !output.startsWith("which:")) {
                    root.cliPath = output;
                } else {
                    // Fallback to common installation paths
                    const home = Qt.getenv("HOME");
                    root.cliPath = home + "/.local/bin/claude";
                }
            }
        }
    }

    // Session management
    property string sessionId: ""

    // Cost tracking
    property real totalCost: 0.0
    property real sessionCost: 0.0

    // Thinking block state
    property bool isThinking: false

    // Current content block type for proper stop handling
    property string currentBlockType: ""

    // Tool mode: "safe", "interactive", "full"
    property string toolMode: "safe"

    // Project directory for file access
    property string projectDir: ""

    // Max turns limit (prevents infinite loops)
    property int maxTurns: 20

    // Show tool activity in UI
    property bool showToolActivity: true

    // Helper: Escape string for bash single quotes
    function escapeForBash(str) {
        // Replace single quotes with '\'' (end quote, escaped quote, start quote)
        return str.replace(/'/g, "'\\''");
    }

    // Direct CLI execution - override from ApiStrategy
    function usesDirectExecution() {
        return true;
    }

    // Build the claude CLI command
    function buildCommand(model, messages, systemPrompt, temperature, tools, filePath) {
        // Get the last user message
        const lastMsg = messages.length > 0 ? messages[messages.length - 1].rawContent : "";

        // Build prompt: include system prompt only for new conversations
        const prompt = sessionId ? lastMsg : (systemPrompt ? systemPrompt + "\n\n" + lastMsg : lastMsg);

        // Build command
        let cmdParts = [];
        cmdParts.push(cliPath);
        cmdParts.push("-p");
        cmdParts.push(prompt);
        cmdParts.push("--output-format");
        cmdParts.push("stream-json");

        // Tool mode kontrolü - hangi araçlara izin verilecek
        if (toolMode === "safe") {
            // Sadece okuma işlemleri - güvenli
            // NOT: mcp__* wildcard kaldırıldı - güvenlik riski
            cmdParts.push("--allowedTools");
            cmdParts.push("Read,Glob,Grep,WebSearch,WebFetch,Task,LS,TodoRead");
        } else if (toolMode === "interactive") {
            // Tüm araçlar açık - hook script onay ister
            // Hook PreToolUse event'inde tehlikeli araçları yakalar
            // Hiçbir --allowedTools kısıtlaması yok
        } else if (toolMode === "full") {
            // Tüm araçlar - onay olmadan
            cmdParts.push("--dangerously-skip-permissions");
        }
        // Default: hiçbir flag eklenmez, Claude kendi varsayılanlarını kullanır

        // Proje dizini - Claude'un dosya erişimi için
        if (projectDir && projectDir.length > 0) {
            cmdParts.push("--add-dir");
            cmdParts.push(projectDir);
        }

        // Max turns - sonsuz döngü koruması
        if (maxTurns > 0) {
            cmdParts.push("--max-turns");
            cmdParts.push(maxTurns.toString());
        }

        // Resume session if we have a session ID
        if (sessionId) {
            cmdParts.push("--resume");
            cmdParts.push(sessionId);
        }

        return cmdParts;
    }

    // Not used for CLI-based strategy
    function buildEndpoint(model) {
        return "local-cli";
    }

    // Not used for CLI-based strategy
    function buildRequestData(model, messages, systemPrompt, temperature, tools, filePath) {
        return {};
    }

    // Not needed - no API key required
    function buildAuthorizationHeader(apiKeyEnvVarName) {
        return "";
    }

    // Parse NDJSON events from Claude CLI stream-json output
    function parseResponseLine(line, message) {
        if (!line || line.trim().length === 0) return {};

        try {
            const dataJson = JSON.parse(line);
            const eventType = dataJson.type;

            switch (eventType) {
                case "system":
                    // Store session ID for continuation
                    if (dataJson.session_id) {
                        sessionId = dataJson.session_id;
                    }
                    return {};

                case "message_start":
                    // Could extract model info here if needed
                    return {};

                case "content_block_start":
                    // Track current block type for proper stop handling
                    currentBlockType = dataJson.content_block?.type || "";

                    // Handle thinking blocks
                    if (currentBlockType === "thinking") {
                        isThinking = true;
                        const startBlock = "\n\n<think>\n\n";
                        message.content += startBlock;
                        message.rawContent += startBlock;
                    }
                    // Handle tool use blocks
                    else if (currentBlockType === "tool_use") {
                        return {
                            toolUseStart: {
                                id: dataJson.content_block.id,
                                name: dataJson.content_block.name
                            }
                        };
                    }
                    return {};

                case "content_block_delta":
                    let text = "";
                    if (dataJson.delta?.type === "thinking_delta") {
                        text = dataJson.delta.thinking || "";
                    } else if (dataJson.delta?.type === "text_delta") {
                        text = dataJson.delta.text || "";
                    } else if (dataJson.delta?.type === "input_json_delta") {
                        // Tool input streaming - accumulate for display
                        return {
                            toolInputDelta: {
                                partial_json: dataJson.delta.partial_json || ""
                            }
                        };
                    }

                    if (text) {
                        message.content += text;
                        message.rawContent += text;
                    }
                    return {};

                case "content_block_stop":
                    // End thinking block if active
                    if (isThinking) {
                        isThinking = false;
                        const endBlock = "\n\n</think>\n\n";
                        message.content += endBlock;
                        message.rawContent += endBlock;
                    }

                    // Signal tool use complete only if we were in a tool_use block
                    const wasToolUse = currentBlockType === "tool_use";
                    currentBlockType = "";  // Reset block type

                    if (wasToolUse) {
                        return { toolUseStop: true };
                    }
                    return {};

                case "assistant":
                    // Assistant message with potential tool_use blocks
                    if (dataJson.message?.content) {
                        for (const block of dataJson.message.content) {
                            if (block.type === "tool_use") {
                                return {
                                    toolUse: {
                                        id: block.id,
                                        name: block.name,
                                        input: block.input
                                    }
                                };
                            }
                        }
                    }
                    return {};

                case "user":
                    // User message with tool_result blocks
                    if (dataJson.message?.content) {
                        for (const block of dataJson.message.content) {
                            if (block.type === "tool_result") {
                                return {
                                    toolResult: {
                                        toolUseId: block.tool_use_id,
                                        content: typeof block.content === "string" ? block.content : JSON.stringify(block.content),
                                        isError: block.is_error || false
                                    }
                                };
                            }
                        }
                    }
                    return {};

                case "message_delta":
                    // Extract token usage if available
                    if (dataJson.usage) {
                        return {
                            tokenUsage: {
                                input: dataJson.usage.input_tokens ?? -1,
                                output: dataJson.usage.output_tokens ?? -1,
                                total: (dataJson.usage.input_tokens ?? 0) + (dataJson.usage.output_tokens ?? 0)
                            }
                        };
                    }
                    return {};

                case "message_stop":
                    // Message complete, but wait for result event for cost
                    return {};

                case "result":
                    // Final event with cost information
                    if (dataJson.cost_usd !== undefined) {
                        sessionCost = dataJson.cost_usd;
                        totalCost += sessionCost;
                    } else if (dataJson.result?.cost_usd !== undefined) {
                        sessionCost = dataJson.result.cost_usd;
                        totalCost += sessionCost;
                    }
                    return { finished: true };

                case "error":
                    const errorMsg = `**Error**: ${dataJson.error?.message || JSON.stringify(dataJson)}`;
                    message.content += errorMsg;
                    message.rawContent += errorMsg;
                    return { finished: true };

                default:
                    // Unknown event type - log but don't fail
                    console.log("[ClaudeCliStrategy] Unknown event type:", eventType);
                    return {};
            }
        } catch (e) {
            console.warn("[ClaudeCliStrategy] Failed to parse line:", line, "Error:", e);
            return {};
        }
    }

    function onRequestFinished(message) {
        // End any unclosed thinking blocks
        if (isThinking) {
            isThinking = false;
            const endBlock = "\n\n</think>\n\n";
            message.content += endBlock;
            message.rawContent += endBlock;
        }
        return {};
    }

    function reset() {
        // Reset thinking state, but keep session for multi-turn
        isThinking = false;
        currentBlockType = "";
        sessionCost = 0.0;
        // Note: sessionId is preserved across messages in the same conversation
        // Call clearSession() explicitly to start a new conversation
    }

    // Explicit session clear - call when user clears chat
    function clearSession() {
        sessionId = "";
        totalCost = 0.0;
        sessionCost = 0.0;
        isThinking = false;
    }
}
