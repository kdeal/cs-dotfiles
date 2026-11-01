# Extensions

## Questionnaire

`questionnaire.ts` registers the `questionnaire` tool for asking one or more questions.

- **TUI mode:** displays the terminal questionnaire with options, custom text entry, and tabs for multiple questions.
- **RPC mode:** sends the complete questionnaire through a single standard `input` dialog. The RPC client renders its own UI and returns all answers in one response.
- **Other modes:** returns a UI-unavailable result.

Question IDs must be unique. The extension normalizes omitted labels to `Q1`, `Q2`, etc., and omitted `allowOther` values to `true`.

### RPC protocol: `questionnaire:v1`

This is a private convention layered on Pi's existing extension UI protocol; it does not require changes to Pi core. Both the extension and the client must support it. A generic RPC client will show an ordinary input dialog instead of a questionnaire.

#### Request (Pi → client)

Recognize records with all three fields:

```json
{
  "type": "extension_ui_request",
  "method": "input",
  "title": "questionnaire:v1"
}
```

Parse the record's `placeholder` string as JSON. Its decoded structure is:

```json
{
  "type": "questionnaire",
  "version": 1,
  "questions": [
    {
      "id": "environment",
      "label": "Environment",
      "prompt": "Which environment?",
      "options": [
        {
          "value": "dev",
          "label": "Development",
          "description": "Local development environment"
        },
        { "value": "prod", "label": "Production" }
      ],
      "allowOther": true
    }
  ]
}
```

For example, the actual JSONL record on stdout looks like:

```json
{"type":"extension_ui_request","id":"request-1","method":"input","title":"questionnaire:v1","placeholder":"{\"type\":\"questionnaire\",\"version\":1,\"questions\":[{\"id\":\"environment\",\"label\":\"Environment\",\"prompt\":\"Which environment?\",\"options\":[{\"value\":\"prod\",\"label\":\"Production\"}],\"allowOther\":true}]}"}
```

The client should validate the payload type and version, then present all questions. Display option labels and descriptions, but retain their underlying `value`. Offer custom text entry only when `allowOther` is true. Keep the request `id` for the response.

#### Submission (client → Pi)

Encode this object as a JSON string:

```json
{
  "version": 1,
  "answers": [
    { "id": "environment", "value": "prod", "wasCustom": false }
  ]
}
```

Send that string as `value` in a standard extension UI response, using the request's exact `id`:

```json
{"type":"extension_ui_response","id":"request-1","value":"{\"version\":1,\"answers\":[{\"id\":\"environment\",\"value\":\"prod\",\"wasCustom\":false}]}"}
```

For custom text, send the entered string as `value` and set `wasCustom` to `true`.

The extension validates that:

- The response has `version: 1` and an `answers` array.
- Every answer has a string `id`, string `value`, and boolean `wasCustom`.
- Every question has exactly one answer; unknown IDs and duplicates are rejected.
- Selected values match an original option.
- Custom answers are allowed by the question.

Labels and one-based option indices are derived from the original questions, not client-supplied fields. Answers are returned in question order. Custom text is trimmed; blank custom text becomes `(no response)`, matching the terminal UI. Malformed responses fail the tool call rather than being treated as successful submissions or user cancellation.

#### Cancellation

Use the standard cancellation response, not a JSON-encoded answer payload:

```json
{"type":"extension_ui_response","id":"request-1","cancelled":true}
```

The tool reports that the questionnaire was cancelled and returns no answers. The tool's abort signal is passed to the input dialog so aborting the operation can release the wait. There is no default timeout; the client should handle unsupported versions or an unavailable UI explicitly rather than silently ignoring the request.

#### Client sketch (TypeScript)

```ts
if (
  record.type === "extension_ui_request" &&
  record.method === "input" &&
  record.title === "questionnaire:v1"
) {
  const payload = JSON.parse(record.placeholder);
  // Validate payload.type, payload.version, and questions before rendering.
  const answers = await showQuestionnaire(payload.questions);
  // Here showQuestionnaire returns undefined for cancellation.
  const response = answers === undefined
    ? { type: "extension_ui_response", id: record.id, cancelled: true }
    : {
        type: "extension_ui_response",
        id: record.id,
        value: JSON.stringify({ version: 1, answers }),
      };
  child.stdin.write(JSON.stringify(response) + "\n");
}
```

Continue reading RPC stdout while the form is open, and honor stdin backpressure in a production client. Each response is one LF-terminated JSON record. Do not send the answers as a new `prompt`: the pending tool call is waiting for an `extension_ui_response`.

### Tests

From the repository root:

```sh
npx --yes tsx --test pi/extensions/tests/questionnaire-rpc.test.ts
```
