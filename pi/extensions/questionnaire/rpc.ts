import type { Question, QuestionnaireResult } from "../questionnaire.ts";

/** Decode the private questionnaire:v1 protocol carried by an RPC input dialog. */
export function parseQuestionnaireResponse(response: string | undefined, questions: Question[]): QuestionnaireResult {
	if (response === undefined) return { questions, answers: [], cancelled: true };

	const payload: unknown = JSON.parse(response);
	if (!isRecord(payload) || payload.version !== 1 || !Array.isArray(payload.answers)) {
		throw new Error("Expected version: 1 and an answers array");
	}

	const byId = new Map(questions.map((q) => [q.id, q]));
	const answers = new Map<string, QuestionnaireResult["answers"][number]>();
	for (const answer of payload.answers) {
		if (
			!isRecord(answer) ||
			typeof answer.id !== "string" ||
			typeof answer.value !== "string" ||
			typeof answer.wasCustom !== "boolean"
		) {
			throw new Error("Each answer requires id, value, and wasCustom");
		}
		const question = byId.get(answer.id);
		if (!question) throw new Error(`Unknown question ID: ${answer.id}`);
		if (answers.has(answer.id)) throw new Error(`Duplicate answer: ${answer.id}`);

		if (answer.wasCustom) {
			if (!question.allowOther) throw new Error(`Custom answer not allowed: ${answer.id}`);
			const value = answer.value.trim() || "(no response)";
			answers.set(answer.id, { id: answer.id, value, label: value, wasCustom: true });
		} else {
			const index = question.options.findIndex((option) => option.value === answer.value);
			if (index === -1) throw new Error(`Invalid option value for: ${answer.id}`);
			const option = question.options[index];
			answers.set(answer.id, {
				id: answer.id,
				value: option.value,
				label: option.label,
				wasCustom: false,
				index: index + 1,
			});
		}
	}

	if (answers.size !== questions.length) throw new Error("All questions must be answered");
	return {
		questions,
		answers: questions.map((q) => answers.get(q.id)!),
		cancelled: false,
	};
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}
