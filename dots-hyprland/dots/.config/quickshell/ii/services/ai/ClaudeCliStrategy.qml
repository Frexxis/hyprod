import QtQuick

ApiStrategy {
    id: root

    // Claude CLI path
    readonly property string cliPath: "/home/muhammetali/.local/bin/claude"

    // Session management
    property string sessionId: ""

    // Cost tracking
    property real totalCost: 0.0
    property real sessionCost: 0.0

    // Thinking block state
    property bool isThinking: false

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

        // Escape for bash
        const escapedPrompt = escapeForBash(prompt);

        // Build command with environment variable for safe prompt passing
        let cmdParts = [];
        cmdParts.push(cliPath);
        cmdParts.push("-p");
        cmdParts.push(prompt);
        cmdParts.push("--output-format");
        cmdParts.push("stream-json");

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
                    // Handle thinking blocks
                    if (dataJson.content_block?.type === "thinking") {
                        isThinking = true;
                        const startBlock = "\n\n<think>\n\n";
                        message.content += startBlock;
                        message.rawContent += startBlock;
                    }
                    return {};

                case "content_block_delta":
                    let text = "";
                    if (dataJson.delta?.type === "thinking_delta") {
                        text = dataJson.delta.thinking || "";
                    } else if (dataJson.delta?.type === "text_delta") {
                        text = dataJson.delta.text || "";
                    } else if (dataJson.delta?.type === "input_json_delta") {
                        // Tool input streaming - could display if needed
                        return {};
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
