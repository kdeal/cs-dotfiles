import assert from "node:assert/strict";
import test from "node:test";
import type { Question } from "../questionnaire.ts";
import { parseQuestionnaireResponse } from "../questionnaire/rpc.ts";

const questions: Question[] = [
	{
		id: "environment",
		label: "Environment",
		prompt: "Which environment?",
		options: [{ value: "prod", label: "Production" }],
		allowOther: false,
	},
	{
		id: "note",
		label: "Note",
		prompt: "Any notes?",
		options: [],
		allowOther: true,
	},
];

const selected = { id: "environment", value: "prod", wasCustom: false };
const custom = { id: "note", value: "  Deploy tomorrow  ", wasCustom: true };
const encode = (answers: unknown[]) => JSON.stringify({ version: 1, answers });

test("normalizes answers in question order and derives display fields locally", () => {
	const result = parseQuestionnaireResponse(
		encode([custom, { ...selected, label: "Untrusted", index: 99 }]),
		questions,
	);
	assert.equal(result.cancelled, false);
	assert.deepEqual(result.answers, [
		{ ...selected, label: "Production", index: 1 },
		{ ...custom, value: "Deploy tomorrow", label: "Deploy tomorrow" },
	]);
});

test("cancellation preserves questions without answers", () => {
	assert.deepEqual(parseQuestionnaireResponse(undefined, questions), {
		questions,
		answers: [],
		cancelled: true,
	});
});

test("empty custom answers match terminal normalization", () => {
	const result = parseQuestionnaireResponse(encode([selected, { ...custom, value: " " }]), questions);
	assert.equal(result.answers[1].value, "(no response)");
});

for (const [name, response] of [
	["malformed JSON", "{"],
	["null payload", "null"],
	["unsupported version", JSON.stringify({ version: 2, answers: [selected, custom] })],
	["missing answers", JSON.stringify({ version: 1 })],
	["missing question", encode([selected])],
	["duplicate answer", encode([selected, custom, custom])],
	["unknown question", encode([selected, { ...custom, id: "unknown" }])],
	["invalid option", encode([{ ...selected, value: "unknown" }, custom])],
	["disallowed custom answer", encode([{ ...selected, wasCustom: true }, custom])],
	["missing discriminator", encode([{ id: "environment", value: "prod" }, custom])],
	["non-string value", encode([selected, { ...custom, value: 42 }])],
	["null answer", encode([selected, null])],
] as const) {
	test(`rejects ${name}`, () => {
		assert.throws(() => parseQuestionnaireResponse(response, questions));
	});
}
