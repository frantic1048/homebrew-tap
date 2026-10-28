"""Update a Homebrew formula with checksums from a GitHub Release.

Expects environment variables:
  FORMULA — formula name (e.g. "blend")
  VERSION — new version (e.g. "0.3.0")
"""

import os
import re
import sys
import urllib.error
import urllib.request

FORMULA_SOURCES = {
    "blend": {
        "repo": "frantic1048/blend",
        "tag_prefix": "blend",
        "homepage": "https://github.com/frantic1048/blend",
        "artifacts": [
            "blend-aarch64-apple-darwin.tar.xz",
            "blend-aarch64-unknown-linux-gnu.tar.xz",
            "blend-x86_64-apple-darwin.tar.xz",
            "blend-x86_64-unknown-linux-gnu.tar.xz",
        ],
    },
}


def parse_checksums(checksum_data):
    """Parse sha256.sum content into a filename-to-digest mapping."""
    checksums = {}
    for line in checksum_data.strip().splitlines():
        parts = line.split()
        if len(parts) == 2:
            checksums[parts[1]] = parts[0]
    return checksums


def update_blend_linux_block(content, repo, tag_prefix, checksums):
    """Render both supported Linux architectures once ARM64 is released."""
    arm_filename = "blend-aarch64-unknown-linux-gnu.tar.xz"
    intel_filename = "blend-x86_64-unknown-linux-gnu.tar.xz"
    block = f'''  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/{repo}/releases/download/{tag_prefix}-v#{{version}}/{arm_filename}"
      sha256 "{checksums[arm_filename]}"
    elsif Hardware::CPU.intel?
      url "https://github.com/{repo}/releases/download/{tag_prefix}-v#{{version}}/{intel_filename}"
      sha256 "{checksums[intel_filename]}"
    else
      odie "blend is not available for this architecture"
    end
  end'''

    content, replacements = re.subn(
        r"  on_linux do\n.*?\n  end\n\n(?=  livecheck do)",
        f"{block}\n\n",
        content,
        count=1,
        flags=re.DOTALL,
    )
    if replacements != 1:
        raise ValueError("Could not locate blend's on_linux formula block")
    return content


def update_formula_content(formula, version, content, checksums):
    """Return updated formula content plus its source repository and tag."""
    url_match = re.search(
        r'url "https://github\.com/([^"]+)/releases/download/([^-]+)-v',
        content,
    )
    if not url_match:
        raise ValueError("Could not extract source repository information")

    current_repo = url_match.group(1)
    current_tag_prefix = url_match.group(2)
    source = FORMULA_SOURCES.get(formula, {})
    repo = source.get("repo", current_repo)
    tag_prefix = source.get("tag_prefix", current_tag_prefix)
    tag = f"{tag_prefix}-v{version}"

    missing = [
        filename for filename in source.get("artifacts", []) if filename not in checksums
    ]
    if missing:
        raise ValueError(f"Release is missing checksums for: {', '.join(missing)}")

    content = re.sub(
        r'(version\s+")[^"]+(")',
        f"\\g<1>{version}\\2",
        content,
    )

    # Point artifact URLs at the configured release repository. This also
    # migrates an existing formula when a project moves repositories.
    content = re.sub(
        r'https://github\.com/[^"]+/releases/download/[^-]+-v',
        f"https://github.com/{repo}/releases/download/{tag_prefix}-v",
        content,
    )

    if homepage := source.get("homepage"):
        content = re.sub(
            r'(^\s*homepage\s+")[^"]+(")',
            f"\\g<1>{homepage}\\2",
            content,
            count=1,
            flags=re.MULTILINE,
        )
        content = content.replace(
            f"# https://github.com/{current_repo}",
            f"# https://github.com/{repo}",
        )

    if formula == "blend":
        content = update_blend_linux_block(content, repo, tag_prefix, checksums)

    missing_formula_checksums = []

    def replace_sha256(match):
        filename = match.group(2)
        if filename not in checksums:
            missing_formula_checksums.append(filename)
            return match.group(0)
        indent = match.group(3)
        return f'url "{match.group(1)}"\n{indent}sha256 "{checksums[filename]}"'

    content = re.sub(
        r'url "(https://[^"]+/([^"/]+\.tar\.xz))"\n(\s+)sha256 "[^"]+"',
        replace_sha256,
        content,
    )
    if missing_formula_checksums:
        missing_names = ", ".join(sorted(set(missing_formula_checksums)))
        raise ValueError(f"Release is missing checksums for: {missing_names}")

    return content, repo, tag


def main():
    formula = os.environ.get("FORMULA", "")
    version = os.environ.get("VERSION", "")
    if not formula or not version:
        sys.exit("FORMULA and VERSION environment variables are required")

    path = f"Formula/{formula}.rb"
    if not os.path.isfile(path):
        sys.exit(f"Formula not found: {path}")

    with open(path) as formula_file:
        content = formula_file.read()

    source = FORMULA_SOURCES.get(formula, {})
    repo = source.get("repo")
    tag_prefix = source.get("tag_prefix")
    if not repo or not tag_prefix:
        url_match = re.search(
            r'url "https://github\.com/([^"]+)/releases/download/([^-]+)-v',
            content,
        )
        if not url_match:
            sys.exit(f"Could not extract source repo info from {path}")
        repo = repo or url_match.group(1)
        tag_prefix = tag_prefix or url_match.group(2)

    tag = f"{tag_prefix}-v{version}"
    checksum_url = f"https://github.com/{repo}/releases/download/{tag}/sha256.sum"
    print(f"Downloading checksums from: {checksum_url}")

    try:
        with urllib.request.urlopen(checksum_url) as response:
            checksum_data = response.read().decode()
    except urllib.error.HTTPError as error:
        sys.exit(f"Failed to download checksums (HTTP {error.code}): {checksum_url}")

    checksums = parse_checksums(checksum_data)
    print(f"Found checksums: {list(checksums.keys())}")

    try:
        content, repo, tag = update_formula_content(
            formula, version, content, checksums
        )
    except ValueError as error:
        sys.exit(str(error))

    with open(path, "w") as formula_file:
        formula_file.write(content)

    if github_output := os.environ.get("GITHUB_OUTPUT"):
        with open(github_output, "a") as output_file:
            output_file.write(f"source_repo={repo}\n")
            output_file.write(f"release_tag={tag}\n")

    print(f"Updated {path} to v{version}")


if __name__ == "__main__":
    main()
