#!/usr/bin/env python3
"""Generate Feel English Tier 1/2/3 documents from the Oxford 3000 PDF."""

from __future__ import annotations

import argparse
import math
import re
from collections import OrderedDict
from dataclasses import dataclass, field
from pathlib import Path

from pypdf import PdfReader


OXFORD_URL = (
    "https://www.oxfordlearnersdictionaries.com/external/pdf/wordlists/"
    "oxford-3000-5000/The_Oxford_3000.pdf"
)
FREQUENCY_URL = (
    "https://github.com/hermitdave/FrequencyWords/blob/master/"
    "content/2018/en/en_50k.txt"
)

CORE_100 = """
get take make go come put keep give bring turn
do have use work try need want help start stop
move stay leave arrive reach return enter follow run walk
see look watch hear listen feel think know understand mean
remember forget learn study read write say tell speak talk
ask answer call show explain find meet wait live spend
pay buy sell send receive choose decide plan change become
grow hold let set pick carry open close break fix
build add cut fill fall raise drop join pass lose
win play happen seem matter like love prefer agree share
""".split()

LEVEL_FACTOR = {"A1": 0.60, "A2": 0.80, "B1": 1.10, "B2": 1.45}
LEVEL_ORDER = {"A1": 0, "A2": 1, "B1": 2, "B2": 3}
ENTRY_END = re.compile(r"\b(?:A1|A2|B1|B2)\s*$")
POS_SPLIT = re.compile(
    r"\s+(?=(?:n\.|v\.|adj\.|adv\.|prep\.|conj\.|pron\.|det\.|"
    r"exclam\.|number\b|ordinal number\b|modal v\.|auxiliary v\.|"
    r"indefinite article\b|definite article\b|linking v\.))"
)


@dataclass
class WordEntry:
    word: str
    source_index: int
    senses: list[tuple[str, str]] = field(default_factory=list)

    @property
    def levels(self) -> list[str]:
        found = {
            level
            for _, metadata in self.senses
            for level in re.findall(r"\b(?:A1|A2|B1|B2)\b", metadata)
        }
        return sorted(found, key=LEVEL_ORDER.get)

    @property
    def minimum_level(self) -> str:
        return self.levels[0]

    @property
    def oxford_label(self) -> str:
        labels = []
        for source_head, metadata in self.senses:
            if len(self.senses) == 1 and normalize_headword(source_head) == self.word:
                labels.append(metadata)
            else:
                labels.append(f"{source_head} — {metadata}")
        return "; ".join(labels)


def normalize_space(value: str) -> str:
    return " ".join(value.replace("\u00a0", " ").split())


def normalize_headword(value: str) -> str:
    value = re.sub(r"\s*\([^)]*\)\s*", " ", value).strip()
    value = re.sub(r"(?<=[A-Za-z])\d+$", "", value)
    return "a/an" if value == "a, an" else value.lower()


def extract_raw_entries(pdf_path: Path) -> list[str]:
    entries: list[str] = []
    for page in PdfReader(str(pdf_path)).pages:
        buffer = ""
        for raw_line in (page.extract_text() or "").splitlines():
            line = normalize_space(raw_line)
            if (
                not line
                or line.startswith("© Oxford")
                or line == "The Oxford 3000™"
                or line.startswith("The Oxford 3000 is the list")
            ):
                continue
            if buffer:
                line = f"{buffer} {line}"
                buffer = ""
            if not ENTRY_END.search(line):
                buffer = line
                continue
            entries.append(line)
        if buffer:
            raise ValueError(f"Unfinished PDF entry: {buffer}")
    if len(entries) != 3000:
        raise ValueError(f"Expected 3000 PDF entries, found {len(entries)}")
    return entries


def merge_headwords(raw_entries: list[str]) -> OrderedDict[str, WordEntry]:
    merged: OrderedDict[str, WordEntry] = OrderedDict()
    for source_index, raw_entry in enumerate(raw_entries):
        parts = POS_SPLIT.split(raw_entry, maxsplit=1)
        if len(parts) != 2:
            raise ValueError(f"Could not parse Oxford entry: {raw_entry}")
        source_head, metadata = parts
        word = normalize_headword(source_head)
        if word not in merged:
            merged[word] = WordEntry(word=word, source_index=source_index)
        merged[word].senses.append((source_head, metadata))
    return merged


def load_frequency_ranks(path: Path) -> dict[str, int]:
    ranks: dict[str, int] = {}
    with path.open(encoding="utf-8") as handle:
        for rank, line in enumerate(handle, start=1):
            token = line.split(maxsplit=1)[0].lower()
            ranks.setdefault(token, rank)
    return ranks


def learning_score(entry: WordEntry, frequency_ranks: dict[str, int]) -> float:
    frequency_rank = frequency_ranks.get(entry.word, 75_000 + entry.source_index)
    score = math.log1p(frequency_rank)
    score += math.log(LEVEL_FACTOR[entry.minimum_level])

    metadata = " ".join(metadata for _, metadata in entry.senses)
    if "v." in metadata:
        score += math.log(0.78)
    if any(tag in metadata for tag in ("prep.", "conj.", "pron.", "det.", "modal v.")):
        score += math.log(0.72)
    if len(entry.senses) > 1 or len(entry.levels) > 1:
        score += math.log(0.88)
    if " " in entry.word:
        score += math.log(1.15)
    return score


def rank_entries(
    entries: OrderedDict[str, WordEntry], frequency_ranks: dict[str, int]
) -> list[WordEntry]:
    missing = [word for word in CORE_100 if word not in entries]
    if missing:
        raise ValueError(f"Core words missing from Oxford PDF: {missing}")
    forced = [entries[word] for word in CORE_100]
    forced_set = set(CORE_100)
    remainder = [entry for word, entry in entries.items() if word not in forced_set]
    remainder.sort(key=lambda entry: (learning_score(entry, frequency_ranks), entry.source_index))
    return forced + remainder


def escape_table(value: str) -> str:
    return value.replace("|", "\\|")


def render_tier(
    tier: int,
    entries: list[WordEntry],
    start_rank: int,
    end_rank: int,
) -> str:
    milestone = {1: 100, 2: 300, 3: 1000}[tier]
    lines = [
        f"# Tier {tier} — {start_rank}~{end_rank}",
        "",
        f"이 문서는 Tier {tier}에서 **새로 학습할 {len(entries)}개**를 담는다. "
        f"이 단계를 마치면 누적 {milestone}개다.",
        "",
        "## 구성 기준",
        "",
        f"- 모든 항목은 [The Oxford 3000 PDF]({OXFORD_URL})에서 추출했다.",
        "- 품사와 CEFR은 PDF 표기를 보존했다.",
        "- 동형어·복수 품사는 한 학습 표제어로 합쳤다.",
        "- Tier 1은 회화 파급력·다의성·chunk 확장성을 기준으로 고정했다.",
        f"- Tier 2~3은 CEFR와 대화 자막 빈도([FrequencyWords]({FREQUENCY_URL}))를 "
        "보조 신호로 사용했다. 이 순서는 Oxford의 공식 Tier가 아니다.",
        "",
        "## 단어 목록",
        "",
        "| 순번 | 표제어 | CEFR | Oxford 표기 |",
        "| ---: | --- | --- | --- |",
    ]
    for rank, entry in enumerate(entries, start=start_rank):
        lines.append(
            f"| {rank} | `{escape_table(entry.word)}` | {', '.join(entry.levels)} | "
            f"{escape_table(entry.oxford_label)} |"
        )
    lines.append("")
    return "\n".join(lines)


def render_index(ranked: list[WordEntry], unique_count: int) -> str:
    level_counts = {level: 0 for level in LEVEL_ORDER}
    for entry in ranked[:1000]:
        for level in entry.levels:
            level_counts[level] += 1
    return f"""# Feel English Tier 목록

## 문서

- [Tier 1](tier-1.md): 1~100, 신규 100개, 누적 100개
- [Tier 2](tier-2.md): 101~300, 신규 200개, 누적 300개
- [Tier 3](tier-3.md): 301~1000, 신규 700개, 누적 1,000개

## 출처와 처리

- 원본: [The Oxford 3000 PDF]({OXFORD_URL})
- PDF 원본 항목: 3,000개
- 동형어를 합친 학습 표제어: {unique_count:,}개
- Tier 1~3 선정: 위 표제어 중 1,000개

Oxford는 이 PDF를 A1~B2의 가장 중요한 3,000단어 목록으로 설명한다. 이 플러그인의 Tier는 공식 Oxford 분류가 아니라, Feel English 학습 목적에 맞게 재배치한 누적 마일스톤이다.

## 사용 규칙

1. 순번대로 무조건 진행하지 말고 사용자의 일상·약점에 맞게 가까운 범위 안에서 순서를 조정한다.
2. Tier 2는 Tier 1을 포함해 누적 300개, Tier 3은 Tier 1~2를 포함해 누적 1,000개로 해석한다.
3. 문서는 중복을 피하기 위해 각 Tier에서 새로 추가되는 표제어만 담는다.
4. 단어를 한국어 뜻으로 암기하지 말고 예문·핵심 이미지·chunk·자기 문장으로 학습한다.

## 선정된 1,000개의 CEFR 포함 현황

하나의 표제어가 여러 품사·레벨을 가지면 각 레벨에 모두 집계한다.

- A1: {level_counts['A1']}
- A2: {level_counts['A2']}
- B1: {level_counts['B1']}
- B2: {level_counts['B2']}
"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pdf", type=Path, required=True)
    parser.add_argument("--frequency-file", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()

    raw_entries = extract_raw_entries(args.pdf)
    merged = merge_headwords(raw_entries)
    ranked = rank_entries(merged, load_frequency_ranks(args.frequency_file))
    if len(ranked) < 1000:
        raise ValueError(f"Need at least 1000 unique headwords, found {len(ranked)}")

    args.output_dir.mkdir(parents=True, exist_ok=True)
    slices = {
        "tier-1.md": (1, 1, 100),
        "tier-2.md": (2, 101, 300),
        "tier-3.md": (3, 301, 1000),
    }
    for filename, (tier, start, end) in slices.items():
        content = render_tier(tier, ranked[start - 1 : end], start, end)
        (args.output_dir / filename).write_text(content, encoding="utf-8")
    (args.output_dir / "tiers.md").write_text(
        render_index(ranked, len(merged)), encoding="utf-8"
    )

    print(f"PDF entries: {len(raw_entries)}")
    print(f"Unique learning headwords: {len(merged)}")
    print("Generated Tier 1/2/3: 100 / 200 / 700 new headwords")


if __name__ == "__main__":
    main()
