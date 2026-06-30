"""Update a Homebrew formula with checksums from a GitHub Release.

Expects environment variables:
  FORMULA — formula name (e.g. "blend")
  VERSION — new version (e.g. "0.3.0")
"""

import os
import re
import sys
import urllib.request
import urllib.error

formula = os.environ.get("FORMULA", "")
version = os.environ.get("VERSION", "")

if not formula or not version:
    sys.exit("FORMULA and VERSION environment variables are required")

path = f"Formula/{formula}.rb"

if not os.path.isfile(path):
    sys.exit(f"Formula not found: {path}")

with open(path) as f:
    content = f.read()

# Extract source repo and tag prefix from existing URL.
# e.g. url "https://github.com/frantic1048/Vanilla/releases/download/blend-v..."
url_match = re.search(
    r'url "https://github\.com/([^"]+)/releases/download/([^-]+)-v',
    content,
)
if not url_match:
    sys.exit(f"Could not extract source repo info from {path}")

repo = url_match.group(1)
tag_prefix = url_match.group(2)
tag = f"{tag_prefix}-v{version}"

# Download checksums from the source release
checksum_url = f"https://github.com/{repo}/releases/download/{tag}/sha256.sum"
print(f"Downloading checksums from: {checksum_url}")

try:
    with urllib.request.urlopen(checksum_url) as resp:
        checksum_data = resp.read().decode()
except urllib.error.HTTPError as e:
    sys.exit(f"Failed to download checksums (HTTP {e.code}): {checksum_url}")

# Parse checksums: "sha256  filename\n"
checksums = {}
for line in checksum_data.strip().splitlines():
    parts = line.split()
    if len(parts) == 2:
        checksums[parts[1]] = parts[0]

print(f"Found checksums: {list(checksums.keys())}")

# Update version
content = re.sub(
    r'(version\s+")[^"]+(")',
    f"\\g<1>{version}\\2",
    content,
)


# Update sha256 values by matching the url line above each sha256
def replace_sha256(m):
    # group(1) = full URL, group(2) = filename only
    filename = m.group(2)
    if filename in checksums:
        return f'url "{m.group(1)}"\n    sha256 "{checksums[filename]}"'
    else:
        print(f"WARNING: no checksum found for {filename}", file=sys.stderr)
        return m.group(0)


content = re.sub(
    r'url "(https://[^"]+/([^"/]+\.tar\.xz))"\n\s+sha256 "[^"]+"',
    replace_sha256,
    content,
)

with open(path, "w") as f:
    f.write(content)

print(f"Updated {path} to v{version}")
