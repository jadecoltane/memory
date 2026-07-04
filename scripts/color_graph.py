#!/usr/bin/env python3
"""给图谱概念节点自动上色。

扫描 concepts/ 下所有概念页，按色环均匀分配颜色（金角度序列，
概念增删时已有颜色尽量少变动），写入 .obsidian/graph.json 的 colorGroups。
新建概念页后跑一遍即可，笔记等其他节点保持默认灰色。
"""

import colorsys
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONCEPTS_DIR = ROOT / "concepts"
GRAPH_JSON = ROOT / ".obsidian" / "graph.json"

GOLDEN_ANGLE = 137.508  # 相邻序号的色相差，保证颜色彼此拉开


def hue_to_rgb_int(hue_deg: float) -> int:
    r, g, b = colorsys.hls_to_rgb(hue_deg / 360, 0.55, 0.85)
    return (round(r * 255) << 16) | (round(g * 255) << 8) | round(b * 255)


def main() -> None:
    concepts = sorted(p.stem for p in CONCEPTS_DIR.glob("*.md"))
    if not concepts:
        print("concepts/ 下没有概念页，未做修改")
        return

    graph = json.loads(GRAPH_JSON.read_text(encoding="utf-8"))
    graph["colorGroups"] = [
        {
            "query": f'path:"concepts/{name}.md"',
            "color": {"a": 1, "rgb": hue_to_rgb_int(i * GOLDEN_ANGLE % 360)},
        }
        for i, name in enumerate(concepts)
    ]
    GRAPH_JSON.write_text(
        json.dumps(graph, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"已为 {len(concepts)} 个概念上色: {', '.join(concepts)}")


if __name__ == "__main__":
    main()
