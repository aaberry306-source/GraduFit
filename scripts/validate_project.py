#!/usr/bin/env python3
"""Offline project integrity checks. Does not compile or validate SwiftUI."""
import json
import re
import struct
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
icon = root / "GraduFit/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
data = icon.read_bytes()
assert data[:8] == b"\x89PNG\r\n\x1a\n", "Icon must be PNG"
width, height, depth, color_type = struct.unpack(">IIBB", data[16:26])
assert (width, height) == (1024, 1024), "Icon must be 1024 square"
assert color_type in (0, 2), "Icon must be opaque grayscale or RGB"
assert 'ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon"' in project
print(f"PASS: {len(sources)} source references, project object links, shared scheme, asset JSON")
print("PASS: AppIcon build setting and opaque 1024x1024 PNG")
print("NOT RUN: Swift compilation, XCTest, Simulator, visual comparison, provider authentication")
