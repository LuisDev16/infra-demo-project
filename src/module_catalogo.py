"""Discover Terraform modules and their input variables from the shared repo."""

import base64
import json
import os
import re
import urllib.parse
import urllib.request


MODULE_REPO = os.environ.get("MODULE_REPO", "LuisDev16/modulos-terraform")
SUPPORTED_CLOUDS = {"azure", "aws"}


def api(path):
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "infra-demo-issue-copilot",
    }
    token = (
        os.environ.get("GH_PLATFORM_TOKEN")
        or os.environ.get("GH_TOKEN")
        or os.environ.get("GITHUB_TOKEN")
    )
    if token:
        headers["Authorization"] = "Bearer " + token
    request = urllib.request.Request("https://api.github.com" + path, headers=headers)
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode())


def discover_modules():
    repo = api("/repos/" + MODULE_REPO)
    default_branch = repo["default_branch"]
    encoded_branch = urllib.parse.quote(default_branch, safe="")
    commit = api("/repos/" + MODULE_REPO + "/commits/" + encoded_branch)["sha"]
    encoded_commit = urllib.parse.quote(commit, safe="")
    tree = api("/repos/" + MODULE_REPO + "/git/trees/" + commit + "?recursive=1")
    if tree.get("truncated"):
        raise RuntimeError("The shared module repository tree is too large to inspect safely.")

    paths = [
        entry["path"]
        for entry in tree.get("tree", [])
        if entry.get("type") == "blob" and entry.get("path", "").endswith("/variables.tf")
    ]
    roots = sorted(
        {
            path.rsplit("/variables.tf", 1)[0]
            for path in paths
            if path.split("/", 1)[0] in SUPPORTED_CLOUDS
        }
    )

    modules = []
    for root in roots:
        encoded_root = urllib.parse.quote(root, safe="/")
        file_data = api(
            "/repos/" + MODULE_REPO + "/contents/" + encoded_root + "/variables.tf?ref=" + encoded_commit
        )
        source = base64.b64decode(file_data["content"]).decode("utf-8", errors="replace")
        variables = []
        for block in re.finditer(
            r'variable\s+"([A-Za-z0-9_]+)"\s*\{(.*?)(?=\n\})', source, re.S
        ):
            name, body = block.group(1), block.group(2)
            type_match = re.search(r"(?m)^\s*type\s*=\s*([^\n]+)", body)
            default_match = re.search(r"(?m)^\s*default\s*=", body)
            description_match = re.search(
                r'(?m)^\s*description\s*=\s*"([^"\n]*)"', body
            )
            variables.append(
                {
                    "name": name,
                    "type": type_match.group(1).strip() if type_match else "any",
                    "required": default_match is None,
                    "description": description_match.group(1) if description_match else "",
                }
            )

        modules.append(
            {
                "path": root,
                "cloud": root.split("/", 1)[0],
                "name": root.rsplit("/", 1)[-1],
                "source": "git::https://github.com/"
                + MODULE_REPO
                + ".git//"
                + root
                + "?ref="
                + commit,
                "variables": variables,
            }
        )
    return modules
