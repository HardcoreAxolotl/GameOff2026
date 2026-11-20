#!/usr/bin/env python3
"""
Utility for creating/registering GameMaker project resources.

Supports common operations needed when working from CLI:
  - create-script: create scripts/<name>/<name>.gml + .yy and register in .yyp/.resource_order
  - add-event: add an event .gml file to an existing object and register it in the object's .yy

Designed for GameMaker 2024+/2026-style project files in this repo.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


def project_root_from(path: Path) -> Path:
    p = path.resolve()
    for cur in [p] + list(p.parents):
        yyps = list(cur.glob("*.yyp"))
        if yyps:
            return cur
    raise FileNotFoundError("Could not find a .yyp project file from the given path.")


def find_yyp(root: Path) -> Path:
    yyps = sorted(root.glob("*.yyp"))
    if not yyps:
        raise FileNotFoundError(f"No .yyp file found in {root}")
    return yyps[0]


def find_resource_order(root: Path) -> Path:
    ros = sorted(root.glob("*.resource_order"))
    if not ros:
        raise FileNotFoundError(f"No .resource_order file found in {root}")
    return ros[0]


def load_gm_json(path: Path) -> Any:
    text = path.read_text(encoding="utf-8")
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        # GameMaker files may include trailing commas; strip them leniently.
        text2 = re.sub(r",(\s*[}\]])", r"\1", text)
        return json.loads(text2)


def dump_gm_json(path: Path, data: Any) -> None:
    # GM commonly uses 2-space indentation and trailing newline.
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def ensure_script_registered(root: Path, name: str, script_path: str) -> tuple[bool, bool]:
    yyp_path = find_yyp(root)
    ro_path = find_resource_order(root)
    yyp = load_gm_json(yyp_path)
    ro = load_gm_json(ro_path)

    changed_yyp = False
    changed_ro = False

    resources = yyp.setdefault("resources", [])
    if not any(r.get("id", {}).get("path") == script_path for r in resources):
        resources.append({"id": {"name": name, "path": script_path}})
        resources.sort(key=lambda r: (r.get("id", {}).get("path", ""), r.get("id", {}).get("name", "")))
        changed_yyp = True

    ro_list = ro.setdefault("ResourceOrderSettings", [])
    if not any(r.get("path") == script_path or r.get("name") == name for r in ro_list):
        ro_list.append({"name": name, "order": 0, "path": script_path})
        ro_list.sort(key=lambda r: (r.get("path", ""), r.get("name", "")))
        changed_ro = True

    if changed_yyp:
        dump_gm_json(yyp_path, yyp)
    if changed_ro:
        dump_gm_json(ro_path, ro)
    return changed_yyp, changed_ro


def create_script(root: Path, name: str, parent: str | None, content: str | None) -> int:
    script_dir = root / "scripts" / name
    script_dir.mkdir(parents=True, exist_ok=True)
    gml_path = script_dir / f"{name}.gml"
    yy_path = script_dir / f"{name}.yy"
    script_rel = f"scripts/{name}/{name}.yy"

    if not gml_path.exists():
        gml_path.write_text(content if content is not None else f"function {name}() {{\n\t\n}}\n", encoding="utf-8")
        print(f"Created {gml_path}")
    else:
        print(f"Exists  {gml_path}")

    parent_obj = {"name": "Scripts", "path": "folders/Scripts.yy"}
    if parent:
        # accept either 'Folders/...' style or display/path form; keep simple
        if "/" in parent:
            parent_obj = {"name": parent.split("/")[-1].replace(".yy", ""), "path": parent if parent.startswith("folders/") else f"folders/{parent}.yy" if not parent.endswith('.yy') else parent}
        else:
            parent_obj = {"name": parent, "path": f"folders/Scripts/{parent}.yy"}

    yy_data = {
        "$GMScript": "v1",
        "%Name": name,
        "isCompatibility": False,
        "isDnD": False,
        "name": name,
        "parent": parent_obj,
        "resourceType": "GMScript",
        "resourceVersion": "2.0",
    }
    if not yy_path.exists():
        dump_gm_json(yy_path, yy_data)
        print(f"Created {yy_path}")
    else:
        print(f"Exists  {yy_path}")

    cy, cro = ensure_script_registered(root, name, script_rel)
    print(f"Registered in .yyp: {'yes' if cy else 'already'}; .resource_order: {'yes' if cro else 'already'}")
    return 0


EVENT_PRESETS = {
    "create": {"eventType": 0, "eventNum": 0, "file": "Create_0.gml"},
    "destroy": {"eventType": 1, "eventNum": 0, "file": "Destroy_0.gml"},
    "step": {"eventType": 3, "eventNum": 0, "file": "Step_0.gml"},
    "begin_step": {"eventType": 3, "eventNum": 1, "file": "Step_1.gml"},
    "end_step": {"eventType": 3, "eventNum": 2, "file": "Step_2.gml"},
    "draw": {"eventType": 8, "eventNum": 0, "file": "Draw_0.gml"},
    "draw_gui": {"eventType": 8, "eventNum": 64, "file": "Draw_64.gml"},
}


def parse_event_spec(spec: str, collision_object: str | None = None) -> dict[str, Any]:
    s = spec.strip().lower().replace("-", "_")
    if s in EVENT_PRESETS:
        p = EVENT_PRESETS[s].copy()
        p["collisionObjectId"] = None
        return p
    m = re.fullmatch(r"alarm_(\d+)", s)
    if m:
        n = int(m.group(1))
        return {"eventType": 2, "eventNum": n, "file": f"Alarm_{n}.gml", "collisionObjectId": None}
    m = re.fullmatch(r"user_(\d+)", s)
    if m:
        n = int(m.group(1))
        return {"eventType": 7, "eventNum": n, "file": f"Other_{n}.gml", "collisionObjectId": None}
    m = re.fullmatch(r"keypress_(\d+)", s)
    if m:
        n = int(m.group(1))
        return {"eventType": 9, "eventNum": n, "file": f"KeyPress_{n}.gml", "collisionObjectId": None}
    m = re.fullmatch(r"collision_(.+)", s)
    if m:
        obj = collision_object or m.group(1)
        # normalize: allow passing oOther or path-like
        obj_name = obj.split("/")[-1].replace(".yy", "")
        return {
            "eventType": 4,
            "eventNum": 0,
            "file": f"Collision_{obj_name}.gml",
            "collisionObjectId": {"name": obj_name, "path": f"objects/{obj_name}/{obj_name}.yy"},
        }
    raise ValueError(f"Unsupported event spec: {spec}")


def add_event(root: Path, object_name: str, event_spec: str, collision_object: str | None, content: str | None) -> int:
    obj_dir = root / "objects" / object_name
    yy_path = obj_dir / f"{object_name}.yy"
    if not yy_path.exists():
        raise FileNotFoundError(f"Object .yy not found: {yy_path}")

    ev = parse_event_spec(event_spec, collision_object)
    gml_path = obj_dir / ev["file"]
    obj_yy = load_gm_json(yy_path)

    if not gml_path.exists():
        gml_path.write_text(content if content is not None else "", encoding="utf-8")
        print(f"Created {gml_path}")
    else:
        print(f"Exists  {gml_path}")

    events = obj_yy.setdefault("eventList", [])
    def same_event(e: dict[str, Any]) -> bool:
        if e.get("eventType") != ev["eventType"] or e.get("eventNum") != ev["eventNum"]:
            return False
        if ev["eventType"] == 4:
            return (e.get("collisionObjectId") or {}).get("name") == (ev.get("collisionObjectId") or {}).get("name")
        return True

    if not any(same_event(e) for e in events):
        entry = {
            "$GMEvent": "v1",
            "%Name": "",
            "collisionObjectId": ev["collisionObjectId"],
            "eventNum": ev["eventNum"],
            "eventType": ev["eventType"],
            "isDnD": False,
            "name": "",
            "resourceType": "GMEvent",
            "resourceVersion": "2.0",
        }
        events.append(entry)
        dump_gm_json(yy_path, obj_yy)
        print(f"Registered event in {yy_path}")
    else:
        print(f"Event already registered in {yy_path}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="Create/register GameMaker scripts and object events.")
    p.add_argument("--project", help="Path inside project or project root (default: cwd search upward).")
    sub = p.add_subparsers(dest="cmd", required=True)

    cs = sub.add_parser("create-script", help="Create and register a script resource.")
    cs.add_argument("name", help="Script/function name (also used as resource name).")
    cs.add_argument("--parent", help="Parent folder name/path under folders/ (default: Scripts).")
    cs.add_argument("--content-file", help="Read initial script content from file.")
    cs.set_defaults(func_cmd="create_script")

    ae = sub.add_parser("add-event", help="Add/register an event to an existing object.")
    ae.add_argument("object", help="Object resource name (e.g. oPlayer).")
    ae.add_argument("event", help="Event spec: create, destroy, step, begin_step, end_step, draw, draw_gui, alarm_N, user_N, keypress_N, collision_<ObjectName>.")
    ae.add_argument("--collision-object", help="Collision object name for collision events.")
    ae.add_argument("--content-file", help="Read initial event content from file.")
    ae.set_defaults(func_cmd="add_event")

    return p


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    start = Path(args.project) if args.project else Path.cwd()
    root = project_root_from(start)

    if args.func_cmd == "create_script":
        content = Path(args.content_file).read_text(encoding="utf-8") if getattr(args, "content_file", None) else None
        return create_script(root, args.name, getattr(args, "parent", None), content)
    if args.func_cmd == "add_event":
        content = Path(args.content_file).read_text(encoding="utf-8") if getattr(args, "content_file", None) else None
        return add_event(root, args.object, args.event, getattr(args, "collision_object", None), content)
    raise AssertionError("Unhandled command")


if __name__ == "__main__":
    raise SystemExit(main())
