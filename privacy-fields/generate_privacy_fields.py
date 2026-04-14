#!/usr/bin/env python3
"""
Generate privacy-fields-field RML (.rml.ttl) from "Export for TM Input" for **green**, **amber**, and/or
**yellow** rows.

- **Green** — ``Type of Match`` = ``green``.
- **Amber** — ``Type of Match`` = ``amber`` (partial ``concernsMaskedObject`` when masked parent unresolved).
- **Yellow** — ``Type of Match`` = ``yellow``: bright-yellow continuation lines — extra
  ``epo:hasMaskableProperty`` (BT-195) POMs on the **same** TriplesMap as the anchor row (anchor
  = first row in the File Name run with a non-empty Iterator, often the green line above).

**Masked object (sheet columns, current layout):** ``L``–``M`` (MG / node hints) are not emitted yet;
``N``–``O`` label/comment for ``epo:concernsMaskedObject`` POM; ``P`` = ``rr:parentTriplesMap`` local name;
``Q`` simplified XPath (documentation); ``R`` = ``joinCondition child`` — used **only** for the
``epo:concernsMaskedObject`` parent link (``rr:parent "."`` + ``rr:child`` from ``R``; ``AJ`` overrides
``R`` when ``AG`` is set). **BT-197** (non-publication justification → code list) always uses
``rr:child`` ``cbc:ReasonCode`` — column ``R`` does **not** apply there.
``AG`` = ``Alt. TriplesMap Masked Object`` — alternative ``rr:parentTriplesMap`` (overrides ``P``). When
``AG`` is set: ``AH``/``AI``/``AJ`` replace ``N``/``O``/``R`` for the masked-object POM (with fallback to
``N``/``O``/``R`` when an alt cell is empty); see sheet column comments on ``AG``–``AJ``.

Defaults: ``src/mappings-unpublished/green``, ``amber``, ``yellow``. Use ``--no-green`` / ``--no-amber``
/ ``--no-yellow`` to skip.

Usage:
  python privacy-fields/generate_privacy_fields.py
  python privacy-fields/generate_privacy_fields.py --no-amber
  python privacy-fields/generate_privacy_fields.py --only-file ND-ReceivedSubmissionCountUnpublish.rml.ttl

Requires: openpyxl
"""

from __future__ import annotations

import argparse
import re
import sys
from collections.abc import Callable
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_XLSX = REPO_ROOT / "privacy-fields" / "Privacy Field Mappings Helper Sheet.xlsx"
DEFAULT_GREEN_DIR = REPO_ROOT / "src" / "mappings-unpublished" / "green"
DEFAULT_AMBER_DIR = REPO_ROOT / "src" / "mappings-unpublished" / "amber"
DEFAULT_YELLOW_DIR = REPO_ROOT / "src" / "mappings-unpublished" / "yellow"
SHEET_NAME = "Export for TM Input"

# Sheet legend: bright yellow + gray font — several BT-195 PredicateObjectMaps on one TriplesMap.
YELLOW_PROLOGUE_COMMENT = """# Yellow (sheet): continuation rows — multiple rr:predicateObjectMap blocks for
# epo:hasMaskableProperty (BT-195) on the same TriplesMap as the anchor row (bright yellow / gray text).
"""

# Sheet legend: amber / dark yellow-orange — no reliable masked-object TriplesMap from CM.
AMBER_PARTIAL_TTL_COMMENT = (
    "# Amber (partial): epo:concernsMaskedObject omitted — CM does not provide enough information "
    "to resolve rr:parentTriplesMap for the masked object (dark yellow/orange row)."
)

H_TYPE = "Type of Match"
H_EXPORT = "Export Line?"
H_FILE = "File Name"
H_TM_MAIN = "TriplesMap Name"
H_TM_LABEL = "TriplesMap Label"
H_SUBJECT_LABEL = "TriplesMap Subject Label"
H_ITERATOR = "Iterator"
H_POM_MASK_LABEL = "POM Masked Object Label"
H_POM_MASK_COMMENT = "POM Masked Object Comment"
H_TM_MASKED = "TriplesMap Masked Object"
H_TM_MASKED_ALT = "Alt. TriplesMap Masked Object"
H_POM_MASK_LABEL_ALT = "Alt. POM Masked Object Label"
H_POM_MASK_COMMENT_ALT = "Alt. POM Masked Object Comment"
H_JOIN_CHILD_ALT = "Alt. joinCondition child"
H_JOIN_CHILD = "joinCondition child"
H_BT195_LABEL = "POM BT-195 Label"
H_BT195_COMMENT = "POM BT-195 Comment"
H_BT195_COND = "POM BT-195 Condition"
H_BT195_VAL = "POM BT-195 Value"
H_BT197_LABEL = "POM BT-197 Label"
H_BT197_COMMENT = "POM BT-197 Comment"
H_BT198_LABEL = "POM BT-198 Label"
H_BT198_COMMENT = "POM BT-198 Comment"
H_BT196_TM = "BT-196 TriplesMap Name"
H_BT196_ITER = "BT-196 TriplesMap Iterator"
H_BT196_LABEL = "POM BT-196 Label"
H_BT196_COMMENT = "POM BT-196 Comment"
H_BT196_LANG_LABEL = "POM BT-196 Language Label"
H_BT196_LANG_COMMENT = "POM BT-196 Language Comment"


def ttl_str(s: str | None) -> str:
    if s is None:
        return '""'
    t = str(s).replace("\\", "\\\\").replace('"', '\\"')
    return f'"{t}"'


def normalize_tedm_local(local: str) -> str:
    s = local.removeprefix("tedm:")
    s = re.sub(
        r"^MG-NonPublishedInformation-ND-",
        "MG-NonPublishedInformation_ND-",
        s,
        count=1,
    )
    s = re.sub(
        r"^MG-langString-hasConfidentialityJustification--NonPublishedInformation-ND-",
        "MG-langString-hasConfidentialityJustification-NonPublishedInformation_ND-",
        s,
        count=1,
    )
    return s


def full_tedm(local_or_prefixed: str) -> str:
    s = local_or_prefixed.strip()
    if s.startswith("tedm:"):
        s = s[5:]
    return "tedm:" + normalize_tedm_local(s)


def has_resolved_masked_parent(row: dict[str, object]) -> bool:
    """True if ``TriplesMap Masked Object`` (P) or ``Alt. TriplesMap Masked Object`` (AG) is non-empty."""
    alt = row.get(H_TM_MASKED_ALT)
    if alt is not None and str(alt).strip():
        return True
    base = row.get(H_TM_MASKED)
    return base is not None and str(base).strip() != ""


def masked_parent_triples_map(row: dict[str, object]) -> str:
    alt = row.get(H_TM_MASKED_ALT)
    base = row.get(H_TM_MASKED)
    chosen = (str(alt).strip() if alt not in (None, "") else None) or base
    if not chosen:
        return "tedm:MG-Procedure_ND-Root"
    return full_tedm(str(chosen))


def uses_alternative_masked_object(row: dict[str, object]) -> bool:
    """True when ``Alt. TriplesMap Masked Object`` (AG) is set — alt label/comment/join columns apply."""
    v = row.get(H_TM_MASKED_ALT)
    return v is not None and str(v).strip() != ""


def effective_pom_mask_label(row: dict[str, object]) -> str:
    if uses_alternative_masked_object(row):
        alt = row.get(H_POM_MASK_LABEL_ALT)
        if alt is not None and str(alt).strip():
            return str(alt).strip()
    base = row.get(H_POM_MASK_LABEL)
    return str(base) if base is not None else ""


def effective_pom_mask_comment(row: dict[str, object]) -> str:
    if uses_alternative_masked_object(row):
        alt = row.get(H_POM_MASK_COMMENT_ALT)
        if alt is not None and str(alt).strip():
            return str(alt).strip()
    base = row.get(H_POM_MASK_COMMENT)
    return str(base) if base is not None else ""


def bt197_join_child(_row: dict[str, object]) -> str:
    """BT-197 → ``tedm:non-publication-justification``: ``rr:child`` is always ``cbc:ReasonCode`` (never ``R``/``AJ``)."""
    return "cbc:ReasonCode"


def masked_object_join_child_if_present(row: dict[str, object]) -> str | None:
    """Join child for ``epo:concernsMaskedObject`` only: ``AJ`` then ``R`` when ``AG`` set; else ``R``."""
    if uses_alternative_masked_object(row):
        aj = row.get(H_JOIN_CHILD_ALT)
        if aj is not None and str(aj).strip():
            return str(aj).strip()
    jc = row.get(H_JOIN_CHILD)
    if jc is not None and str(jc).strip():
        return str(jc).strip()
    return None


def bt195_rml_reference(cond: str, iri: str) -> str:
    safe_iri = str(iri).replace("'", "''")
    inner = f"if (exists({cond})) then '{safe_iri}' else null"
    return ttl_str(inner)


def row_match_type_green(row: dict[str, object]) -> bool:
    return str(row.get(H_TYPE) or "").strip().lower() == "green"


def row_match_type_amber(row: dict[str, object]) -> bool:
    return str(row.get(H_TYPE) or "").strip().lower() == "amber"


def row_match_type_yellow(row: dict[str, object]) -> bool:
    return str(row.get(H_TYPE) or "").strip().lower() == "yellow"


def load_sheet(
    xlsx: Path,
) -> tuple[list[str], list[tuple[int, dict[str, object]]]]:
    import openpyxl

    wb = openpyxl.load_workbook(xlsx, read_only=False, data_only=True)
    try:
        ws = wb[SHEET_NAME]
        it = ws.iter_rows(values_only=True)
        header = [c for c in next(it)]
        headers = [str(h) if h is not None else "" for h in header]
        if H_FILE not in headers:
            raise SystemExit(f'Sheet missing "{H_FILE}" header')

        rows_out: list[tuple[int, dict[str, object]]] = []
        for excel_row, row in enumerate(it, start=2):
            if not row:
                continue
            d = {headers[i]: row[i] if i < len(row) else None for i in range(len(headers))}
            rows_out.append((excel_row, d))
        return headers, rows_out
    finally:
        wb.close()


def _export_true(row: dict[str, object]) -> bool:
    export = row.get(H_EXPORT)
    return export is True or str(export).lower() in ("true", "1", "yes")


def iter_export_runs_numbered(
    numbered: list[tuple[int, dict[str, object]]],
) -> list[list[tuple[int, dict[str, object]]]]:
    runs: list[list[tuple[int, dict[str, object]]]] = []
    current: list[tuple[int, dict[str, object]]] = []
    current_fn: str | None = None

    for rnum, row in numbered:
        if not _export_true(row):
            if current:
                runs.append(current)
                current = []
            current_fn = None
            continue
        fn = str(row.get(H_FILE) or "").strip()
        if not fn or fn == "---":
            if current:
                runs.append(current)
                current = []
            current_fn = None
            continue
        if current_fn is not None and fn != current_fn:
            runs.append(current)
            current = []
        current.append((rnum, row))
        current_fn = fn
    if current:
        runs.append(current)
    return runs


def anchor_row_from_run(run: list[tuple[int, dict[str, object]]]) -> dict[str, object]:
    for _, r in run:
        if str(r.get(H_ITERATOR) or "").strip():
            return r
    return run[0][1]


def anchor_rnum_from_run(run: list[tuple[int, dict[str, object]]], anchor: dict[str, object]) -> int:
    for rnum, r in run:
        if r is anchor:
            return rnum
    return run[0][0]


def merge_row(anchor: dict[str, object], overlay: dict[str, object]) -> dict[str, object]:
    keys = set(anchor) | set(overlay)
    return {k: (overlay.get(k) if _nonempty(overlay.get(k)) else anchor.get(k)) for k in keys}


def _nonempty(v: object) -> bool:
    if v is None:
        return False
    return str(v).strip() != ""


def mapping_comment_slug(filename: str) -> str:
    s = Path(filename).stem
    if s.endswith(".rml"):
        s = s[: -len(".rml")]
    return s


def render_prefix_block() -> str:
    return """#--- {slug} ---
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix rr: <http://www.w3.org/ns/r2rml#> .
@prefix rml: <http://semweb.mmlab.be/ns/rml#> .
@prefix ql: <http://semweb.mmlab.be/ns/ql#> .
@prefix locn: <http://www.w3.org/ns/locn#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix tedm: <http://data.europa.eu/a4g/mapping/rml/> .
@prefix epd: <http://data.europa.eu/a4g/resource/> .
@prefix epo: <http://data.europa.eu/a4g/ontology#> .
@prefix epo-not: <http://data.europa.eu/a4g/ontology#>.
@prefix cv: <http://data.europa.eu/m8g/> .
@prefix cccev: <http://data.europa.eu/m8g/> .
@prefix org: <http://www.w3.org/ns/org#> .
@prefix cpov: <http://data.europa.eu/m8g/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix time: <http://www.w3.org/2006/time#>.
@prefix adms: <http://www.w3.org/ns/adms#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix fnml:   <http://semweb.mmlab.be/ns/fnml#> .
@prefix fno: <https://w3id.org/function/ontology#> .
@prefix idlab-fn: <http://example.com/idlab/function/> .
"""


def render_bt195_pom(row: dict[str, object]) -> str:
    return f"""	rr:predicateObjectMap
        [
			rdfs:label {ttl_str(str(row[H_BT195_LABEL]))} ;
    		rdfs:comment {ttl_str(str(row[H_BT195_COMMENT]))} ;
            rr:predicate epo:hasMaskableProperty ;
            rr:objectMap
                [
                    rml:reference {bt195_rml_reference(str(row[H_BT195_COND]), str(row[H_BT195_VAL]))} ;
                    rr:termType rr:IRI ;
                ] ;
        ] ;
"""


def render_rml(
    anchor: dict[str, object],
    nd_comment_slug: str,
    extra_bt195_rows: list[dict[str, object]] | None = None,
    *,
    omit_concerns_masked_object: bool = False,
    ttl_prologue_after_slug: str | None = None,
) -> str:
    extra_bt195_rows = extra_bt195_rows or []
    tm_main = full_tedm(str(anchor[H_TM_MAIN]))
    tm_lang = full_tedm(str(anchor[H_BT196_TM]))
    tm_label = str(anchor[H_TM_LABEL])
    subj_label = str(anchor[H_SUBJECT_LABEL])
    iterator = str(anchor[H_ITERATOR])
    pom_mask_l = effective_pom_mask_label(anchor)
    pom_mask_c = effective_pom_mask_comment(anchor)
    parent_masked = masked_parent_triples_map(anchor)
    bt197_l = str(anchor[H_BT197_LABEL])
    bt197_c = str(anchor[H_BT197_COMMENT])
    bt198_l = str(anchor[H_BT198_LABEL])
    bt198_c = str(anchor[H_BT198_COMMENT])
    bt196_iter = str(anchor[H_BT196_ITER])
    bt196_l = str(anchor[H_BT196_LABEL])
    bt196_c = str(anchor[H_BT196_COMMENT])
    bt196_ll = str(anchor[H_BT196_LANG_LABEL])
    bt196_lc = str(anchor[H_BT196_LANG_COMMENT])
    jc = bt197_join_child(anchor)
    mask_join_child = masked_object_join_child_if_present(anchor)
    bt195_l = str(anchor[H_BT195_LABEL])

    notice_pom_label = f"{subj_label} (concernsNotice)"
    notice_pom_comment = "Connection from NonPublishedInformation to Notice under MG-Notice_ND-Root"

    head = render_prefix_block().format(slug=nd_comment_slug)
    if ttl_prologue_after_slug:
        head += ttl_prologue_after_slug
    extra_bt195_blocks = "".join(render_bt195_pom(r) for r in extra_bt195_rows)

    if omit_concerns_masked_object:
        concerns_masked_block = f"    {AMBER_PARTIAL_TTL_COMMENT}\n"
    else:
        mask_join_ttl = ""
        if mask_join_child is not None:
            mask_join_ttl = f"""
                    rr:joinCondition [
                        rr:parent {ttl_str(".")} ;
                        rr:child {ttl_str(mask_join_child)} ;
                    ] ;"""
        concerns_masked_block = f"""    rr:predicateObjectMap
        [
			rdfs:label {ttl_str(pom_mask_l)} ;
			rdfs:comment {ttl_str(pom_mask_c)} ;
            rr:predicate epo:concernsMaskedObject ;
            rr:objectMap
                [
                    rr:parentTriplesMap {parent_masked} ;{mask_join_ttl}
                ] ;
        ] ;
"""

    return f"""{head}
{tm_main} a rr:TriplesMap ;
    rdfs:label {ttl_str(tm_label)} ;
    rml:logicalSource
        [
            rml:source "data/source.xml" ;
            rml:iterator {ttl_str(iterator)} ;
            rml:referenceFormulation ql:XPath
        ] ;
	rr:subjectMap
        [
            rdfs:label {ttl_str(subj_label)} ;
            rr:template "http://data.europa.eu/a4g/resource/{{/*/cbc:ID[@schemeName='notice-id']}}-{{/*/cbc:VersionID}}/NonPublishedInformation${{replace(translate(path(), concat(codepoints-to-string(123), codepoints-to-string(125), '/[]'), '  _'), 'Q .*? ', '')}}" ;
            rr:class epo:NonPublishedInformation
        ] ;
{concerns_masked_block}	rr:predicateObjectMap
        [
    		rdfs:label {ttl_str(notice_pom_label)} ;
    		rdfs:comment {ttl_str(notice_pom_comment)} ;
            rr:predicate epo:concernsNotice ;
            rr:objectMap
                [
                    rr:parentTriplesMap tedm:MG-Notice_ND-Root ;
                ] ;
        ] ;
{render_bt195_pom(anchor)}{extra_bt195_blocks}    # {bt195_l}-List Not needed.
	rr:predicateObjectMap
        [
          rdfs:label {ttl_str(bt197_l)} ;
		  rdfs:comment {ttl_str(bt197_c)} ;
		  rr:predicate epo:hasNonPublicationJustification ;
            rr:objectMap
                [
                    rdfs:label "at-voc:non-publication-justification" ;
                    rr:parentTriplesMap tedm:non-publication-justification ;
                    rr:joinCondition [
                        rr:child  {ttl_str(jc)} ;
                        rr:parent "code.value" ;
                    ] ;
                ] ;
        ] ;
	rr:predicateObjectMap
        [

            rdfs:label {ttl_str(bt198_l)} ;
            rdfs:comment {ttl_str(bt198_c)} ;
            rr:predicate epo:hasAccessibilityDate ;
            rr:objectMap
                [
                    rml:reference "efbc:PublicationDate" ;
                    rr:datatype xsd:date ;
                ] ;
        ] ;
.

{tm_lang} a rr:TriplesMap ;
    rml:logicalSource [
        rml:source "data/source.xml" ;
        rml:iterator {ttl_str(bt196_iter)} ;
        rml:referenceFormulation ql:XPath ;
    ] ;
    rr:subjectMap [
        rr:class epo:NonPublishedInformation ;
        rdfs:label {ttl_str(subj_label)} ;
        rr:template "http://data.europa.eu/a4g/resource/{{/*/cbc:ID[@schemeName='notice-id']}}-{{/*/cbc:VersionID}}/NonPublishedInformation${{replace(translate(path(..), concat(codepoints-to-string(123), codepoints-to-string(125), '/[]'), '  _'), 'Q .*? ', '')}}" ;
    ] ;
    rr:predicateObjectMap [
        rr:predicate epo:hasConfidentialityJustification ;
        rr:objectMap [
            rml:reference "if(exists(@languageID)) then . else null" ;
            rml:languageMap [
                fnml:functionValue [
                    rr:predicateObjectMap [
                        rr:predicate idlab-fn:str ;
                        rr:objectMap [
                            rml:reference "@languageID" ;
                        ] ;
                    ] ;
                    rr:predicateObjectMap tedm:idlab-fn_executes_lookup ;
                    rr:predicateObjectMap tedm:idlab-fn_fromColumn_code ;
                    rr:predicateObjectMap tedm:idlab-fn_inputFile_language ;
                    rr:predicateObjectMap tedm:idlab-fn_toColumn_code ;
                ] ;
            ] ;
            rdfs:comment {ttl_str(bt196_lc)} ;
            rdfs:label {ttl_str(bt196_ll)} ;
        ] ;
        rdfs:comment {ttl_str(bt196_c)} ;
        rdfs:label {ttl_str(bt196_l)} ;
    ] ;
    rdfs:label {ttl_str(tm_label)} .
"""


def emit_for_match_type(
    *,
    numbered: list[tuple[int, dict[str, object]]],
    runs: list[list[tuple[int, dict[str, object]]]],
    type_name: str,
    row_matches: Callable[[dict[str, object]], bool],
    output_dir: Path,
    only_file: str | None,
    omit_concerns_masked_for_anchor: Callable[[dict[str, object]], bool],
) -> int:
    """Return number of files written."""
    typed_rows: list[tuple[int, dict[str, object], str]] = []
    for rnum, row in numbered:
        if not _export_true(row):
            continue
        fn_s = str(row.get(H_FILE) or "").strip()
        if not fn_s or fn_s == "---":
            continue
        if row_matches(row):
            typed_rows.append((rnum, row, fn_s))

    if only_file:
        t = only_file.strip()
        typed_rows = [(r, row, fn) for r, row, fn in typed_rows if fn == t]

    target_fns = {fn for _, _, fn in typed_rows}
    if not target_fns:
        print(f'No rows with Type of Match "{type_name}" to emit.', file=sys.stderr)
        return 0

    output_dir.mkdir(parents=True, exist_ok=True)
    n = 0
    for run in runs:
        fn0 = str(run[0][1].get(H_FILE) or "").strip()
        if fn0 not in target_fns:
            continue
        in_run = [(r, row) for r, row in run if row_matches(row)]
        if not in_run:
            continue
        anchor = anchor_row_from_run(run)
        anchor_r = anchor_rnum_from_run(run, anchor)
        merged_extras = [merge_row(anchor, row) for r, row in in_run if r != anchor_r]
        nd_slug = mapping_comment_slug(fn0)
        omit_masked = omit_concerns_masked_for_anchor(anchor)
        out_path = output_dir / fn0
        out_path.write_text(
            render_rml(
                anchor,
                nd_slug,
                merged_extras,
                omit_concerns_masked_object=omit_masked,
            ),
            encoding="utf-8",
        )
        partial = " [partial: no concernsMaskedObject POM]" if omit_masked else ""
        print(
            f"Wrote {out_path} ({type_name}: anchor + {len(merged_extras)} extra BT-195 POM(s)){partial}"
        )
        n += 1
    return n


def emit_yellow(
    *,
    numbered: list[tuple[int, dict[str, object]]],
    runs: list[list[tuple[int, dict[str, object]]]],
    output_dir: Path,
    only_file: str | None,
) -> int:
    """Yellow rows add extra BT-195 POMs; anchor is iterator row (may be green, not yellow)."""
    typed_rows: list[tuple[int, dict[str, object], str]] = []
    for rnum, row in numbered:
        if not _export_true(row):
            continue
        fn_s = str(row.get(H_FILE) or "").strip()
        if not fn_s or fn_s == "---":
            continue
        if row_match_type_yellow(row):
            typed_rows.append((rnum, row, fn_s))

    if only_file:
        t = only_file.strip()
        typed_rows = [(r, row, fn) for r, row, fn in typed_rows if fn == t]

    target_fns = {fn for _, _, fn in typed_rows}
    if not target_fns:
        print('No rows with Type of Match "yellow" to emit.', file=sys.stderr)
        return 0

    output_dir.mkdir(parents=True, exist_ok=True)
    n = 0
    for run in runs:
        fn0 = str(run[0][1].get(H_FILE) or "").strip()
        if fn0 not in target_fns:
            continue
        yellow_in_run = [(r, row) for r, row in run if row_match_type_yellow(row)]
        if not yellow_in_run:
            continue
        anchor = anchor_row_from_run(run)
        anchor_r = anchor_rnum_from_run(run, anchor)
        merged_extras = [
            merge_row(anchor, row) for r, row in yellow_in_run if r != anchor_r
        ]
        nd_slug = mapping_comment_slug(fn0)
        out_path = output_dir / fn0
        out_path.write_text(
            render_rml(
                anchor,
                nd_slug,
                merged_extras,
                omit_concerns_masked_object=False,
                ttl_prologue_after_slug=YELLOW_PROLOGUE_COMMENT,
            ),
            encoding="utf-8",
        )
        print(
            f"Wrote {out_path} (yellow: anchor row + {len(merged_extras)} continuation BT-195 POM(s))"
        )
        n += 1
    return n


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--xlsx", type=Path, default=DEFAULT_XLSX)
    parser.add_argument(
        "--green-dir",
        type=Path,
        default=DEFAULT_GREEN_DIR,
        help="Output directory for Type of Match = green",
    )
    parser.add_argument(
        "--amber-dir",
        type=Path,
        default=DEFAULT_AMBER_DIR,
        help="Output directory for Type of Match = amber",
    )
    parser.add_argument(
        "--yellow-dir",
        type=Path,
        default=DEFAULT_YELLOW_DIR,
        help="Output directory for Type of Match = yellow (multi BT-195 on same TM)",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="Deprecated: same as --green-dir if set",
    )
    parser.add_argument("--no-green", action="store_true", help="Skip green generation")
    parser.add_argument("--no-amber", action="store_true", help="Skip amber generation")
    parser.add_argument("--no-yellow", action="store_true", help="Skip yellow generation")
    parser.add_argument("--only-file", type=str, default=None)
    args = parser.parse_args()

    if not args.xlsx.is_file():
        print(f"Missing {args.xlsx}", file=sys.stderr)
        sys.exit(1)

    green_dir = args.output_dir if args.output_dir is not None else args.green_dir

    headers, numbered = load_sheet(args.xlsx)
    required = [
        H_TYPE,
        H_FILE,
        H_TM_MAIN,
        H_TM_LABEL,
        H_SUBJECT_LABEL,
        H_ITERATOR,
        H_POM_MASK_LABEL,
        H_POM_MASK_COMMENT,
        H_TM_MASKED,
        H_BT195_LABEL,
        H_BT195_COMMENT,
        H_BT195_COND,
        H_BT195_VAL,
        H_BT197_LABEL,
        H_BT197_COMMENT,
        H_BT198_LABEL,
        H_BT198_COMMENT,
        H_BT196_TM,
        H_BT196_ITER,
        H_BT196_LABEL,
        H_BT196_COMMENT,
        H_BT196_LANG_LABEL,
        H_BT196_LANG_COMMENT,
    ]
    missing = [h for h in required if h not in headers]
    if missing:
        print(f"Sheet missing headers: {missing}", file=sys.stderr)
        sys.exit(1)

    runs = iter_export_runs_numbered(numbered)
    total = 0

    if not args.no_green:
        total += emit_for_match_type(
            numbered=numbered,
            runs=runs,
            type_name="green",
            row_matches=row_match_type_green,
            output_dir=green_dir,
            only_file=args.only_file,
            omit_concerns_masked_for_anchor=lambda _a: False,
        )

    if not args.no_amber:
        total += emit_for_match_type(
            numbered=numbered,
            runs=runs,
            type_name="amber",
            row_matches=row_match_type_amber,
            output_dir=args.amber_dir,
            only_file=args.only_file,
            omit_concerns_masked_for_anchor=lambda a: not has_resolved_masked_parent(a),
        )

    if not args.no_yellow:
        total += emit_yellow(
            numbered=numbered,
            runs=runs,
            output_dir=args.yellow_dir,
            only_file=args.only_file,
        )

    any_enabled = (not args.no_green) or (not args.no_amber) or (not args.no_yellow)
    if total == 0 and any_enabled:
        sys.exit(1)


if __name__ == "__main__":
    main()
