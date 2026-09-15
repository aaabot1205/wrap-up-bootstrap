"""Validate host extensions separately, then run unmodified Skill Creator core checks.

Requires PyYAML and --validator pointing to the installed quick_validate.py.
The temporary core projection is not the installed skill or a host behavior test.
"""
import argparse
import hashlib
import importlib.util
from pathlib import Path
import shutil
import tempfile

import yaml


class UniqueLoader(yaml.SafeLoader):
    pass


def unique_mapping(loader, node):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node)
        if key in result:
            raise ValueError(f"Duplicate YAML key: {key}")
        result[key] = loader.construct_object(value_node)
    return result


UniqueLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, unique_mapping)


def validate(skill, core):
    entry = skill / 'SKILL.md'
    original = entry.read_text(encoding='utf-8')
    lines = original.splitlines(keepends=True)
    if not lines or lines[0].strip() != '---':
        raise ValueError('Missing frontmatter')
    end = next(i for i in range(1, len(lines)) if lines[i].strip() == '---')
    metadata = yaml.load(''.join(lines[1:end]), Loader=UniqueLoader)
    if not isinstance(metadata, dict) or metadata.get('disable-model-invocation') is not True:
        raise ValueError('disable-model-invocation must be boolean true')
    extension = [i for i in range(1, end) if lines[i].startswith('disable-model-invocation:')]
    if len(extension) != 1:
        raise ValueError('Expected one top-level invocation extension')
    policy = yaml.load((skill / 'agents/openai.yaml').read_text(encoding='utf-8'), Loader=UniqueLoader)
    if not isinstance(policy, dict) or not isinstance(policy.get('policy'), dict):
        raise ValueError('Missing Codex policy')
    if policy['policy'].get('allow_implicit_invocation') is not False:
        raise ValueError('allow_implicit_invocation must be boolean false')
    with tempfile.TemporaryDirectory(prefix='skill-core-validation-') as temporary:
        projected = Path(temporary)
        # Remove only the independently validated extension. Retain all other
        # source bytes as decoded text, including unknown fields and the body.
        (projected / 'SKILL.md').write_text(''.join(line for i, line in enumerate(lines) if i != extension[0]), encoding='utf-8')
        passed, reason = core.validate_skill(projected)
        if not passed:
            raise ValueError(reason)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--validator', type=Path, required=True)
    args = parser.parse_args()
    spec = importlib.util.spec_from_file_location('skill_creator_core', args.validator)
    core = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(core)
    root = Path(__file__).resolve().parent
    for name in ('bootstrap', 'wrap-up'):
        skill = root / name
        before = {p.relative_to(skill): hashlib.sha256(p.read_bytes()).hexdigest() for p in skill.rglob('*') if p.is_file()}
        validate(skill, core)
        # The adapter must not conceal malformed extensions or unrelated errors.
        with tempfile.TemporaryDirectory(prefix='skill-validation-negative-') as temporary:
            candidate = Path(temporary) / name
            shutil.copytree(skill, candidate)
            entry = candidate / 'SKILL.md'
            original = entry.read_text(encoding='utf-8')
            for bad in (
                original.replace('disable-model-invocation: true', 'disable-model-invocation: false'),
                original.replace('disable-model-invocation: true', 'disable-model-invocation: "true"'),
                original.replace('disable-model-invocation: true', ''),
                original.replace('disable-model-invocation: true', 'disable-model-invocation: true\ndisable-model-invocation: true'),
                original.replace('disable-model-invocation: true', 'disable-model-invocation: true\nunknown-field: true'),
                original.replace(f'name: {name}', 'name: INVALID_NAME'),
            ):
                entry.write_text(bad, encoding='utf-8')
                try:
                    validate(candidate, core)
                except ValueError:
                    continue
                raise AssertionError('Invalid skill accepted by compatibility validation')
        after = {p.relative_to(skill): hashlib.sha256(p.read_bytes()).hexdigest() for p in skill.rglob('*') if p.is_file()}
        assert before == after, 'Validation changed source files'
        print(f'[PASS] {name}: host policy + unmodified Skill Creator core projection; 6 invalid variants rejected; source hashes unchanged.')


if __name__ == '__main__':
    main()
