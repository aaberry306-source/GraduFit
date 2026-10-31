#!/usr/bin/env python3
"""Offline project integrity checks. Does not compile or validate SwiftUI."""
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

root = Path(__file__).resolve().parents[1]
project = (root / "GraduFit.xcodeproj/project.pbxproj").read_text()
definitions = re.findall(r"^([A-F0-9]{24}) = ", project, re.M)
assert len(definitions) == len(set(definitions)), "Duplicate project object IDs"
references = set(re.findall(r"\b[A-F0-9]{24}\b", project))
assert references == set(definitions), "Dangling project object reference"
sources = re.findall(r'lastKnownFileType = sourcecode.swift; path = "([^"]+)";', project)
assert len(sources) == len(set(sources)), "Duplicate source references"
for source in sources:
    assert (root / source).is_file(), f"Missing source: {source}"
expected = {str(p.relative_to(root)) for folder in ["GraduFit", "CoreTests", "GraduFitUITests"]
            for p in (root / folder).rglob("*.swift")}
assert expected == set(sources), "Swift source missing from Xcode project"
scheme = ET.parse(root / "GraduFit.xcodeproj/xcshareddata/xcschemes/GraduFit.xcscheme")
for reference in scheme.findall(".//BuildableReference"):
    assert reference.attrib["BlueprintIdentifier"] in references
assert len(scheme.findall(".//TestableReference")) == 2
for asset in (root / "GraduFit/Resources").rglob("*.json"):
    json.loads(asset.read_text())
print(f"PASS: {len(sources)} source references, project object links, shared scheme, asset JSON")
print("NOT RUN: Swift compilation, XCTest, Simulator, visual comparison, provider authentication")
