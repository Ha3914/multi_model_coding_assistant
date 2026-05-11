from app.schemas import RepoFile


def build_repo_context(repo_files: list[RepoFile], max_files: int = 20, max_chars: int = 18000) -> str:
    if not repo_files:
        return "未提供仓库文件。"

    used_chars = 0
    blocks: list[str] = []
    for file in repo_files[:max_files]:
        budget = max_chars - used_chars
        if budget <= 0:
            break
        snippet = file.content[: max(0, budget - 120)]
        block = f"\n### 文件: {file.path}\n```\n{snippet}\n```\n"
        blocks.append(block)
        used_chars += len(block)

    return "\n".join(blocks) if blocks else "仓库文件过大，未能截取到有效内容。"
