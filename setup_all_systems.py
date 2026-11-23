#!/usr/bin/env python3
"""
Setup script for all four systems in the capstone project.
This creates venvs, installs dependencies, and runs tests for each system.
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

# System configurations
SYSTEMS = {
    "1-claims-intake": {
        "name": "Claims Intake Agent",
        "path": "/voc/work/py3.13-exercises-and-project/Build a Claims Intake Agent with a stop_reason-Driven Loop/exercises/03-dynamic-decomposition/solution",
        "run_cmd": "python -m claims_intake.run --all",
    },
    "2-retail-context": {
        "name": "Retail Support Context Strategy",
        "path": "/voc/work/py3.13-exercises-and-project/Engineer a Long-Conversation Context Strategy for a Retail Support Copilot/04-assemble-and-locate/solution",
        "run_cmd": "python -m retail_context.run --all",
    },
    "3-ecommerce-config": {
        "name": "E-Commerce Team Claude Code Config",
        "path": "/voc/work/py3.13-exercises-and-project/Configure Claude Code for a Multi-Surface Monorepo Team/04-plan-mode-and-explore-decision-doc/solution",
        "run_cmd": "python -m ecommerce_team_config .",
    },
    "4-shift-monitor": {
        "name": "Multi-Shift Quality Monitoring",
        "path": "/voc/work/py3.13-exercises-and-project/Build a Multi-Shift Quality Monitoring System with Claude Orchestration/04-fork-scratchpad/solution",
        "run_cmd": None,  # Manual setup needed
    },
}

CAPSTONE_DIR = Path("/voc/work/py3.13-exercises-and-project/Project-Harness Engineering with Claude and Claude Code")
EVIDENCE_DIR = CAPSTONE_DIR / "evidence"


def run_command(cmd, cwd=None, shell=False):
    """Run a shell command and return the result."""
    if isinstance(cmd, str):
        cmd = cmd.split()
    print(f"  Running: {' '.join(cmd)}")
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            shell=shell,
            capture_output=False,
            text=True,
        )
        return result.returncode == 0
    except Exception as e:
        print(f"  ERROR: {e}")
        return False


def setup_system(system_id, system_config):
    """Set up a single system."""
    print(f"\n{'=' * 60}")
    print(f"System {system_id}: {system_config['name']}")
    print(f"{'=' * 60}")

    system_path = Path(system_config["path"])

    if not system_path.exists():
        print(f"ERROR: System path not found: {system_path}")
        return False

    print(f"Path: {system_path}")

    # Create venv
    venv_path = system_path / ".venv"
    if venv_path.exists():
        print(f"Removing existing venv...")
        shutil.rmtree(venv_path)

    print(f"1. Creating virtual environment...")
    if not run_command([sys.executable, "-m", "venv", str(venv_path), "--without-pip"], cwd=str(system_path)):
        print(f"ERROR: Failed to create venv")
        return False

    # Bootstrap pip
    print(f"2. Bootstrapping pip...")
    python_bin = venv_path / "bin" / "python3"

    # Try using get-pip.py
    get_pip_path = Path("/tmp/get-pip.py")
    if not get_pip_path.exists():
        print("  Downloading get-pip.py...")
        subprocess.run(
            ["curl", "-s", "https://bootstrap.pypa.io/get-pip.py", "-o", str(get_pip_path)],
            check=False
        )

    if get_pip_path.exists():
        subprocess.run([str(python_bin), str(get_pip_path)], cwd=str(system_path))

    # Install dependencies
    print(f"3. Installing dependencies...")
    pip_bin = venv_path / "bin" / "pip"
    if pip_bin.exists():
        subprocess.run([str(pip_bin), "install", "--upgrade", "pip", "setuptools", "wheel"], cwd=str(system_path))
        subprocess.run([str(pip_bin), "install", "-e", ".[dev]"], cwd=str(system_path))
    else:
        print("  WARNING: pip not available, cannot install dependencies")
        print("  Try installing manually with:")
        print(f"    cd {system_path}")
        print(f"    {python_bin} -m pip install -e .[dev]")

    # Run tests
    print(f"4. Running tests...")
    test_log = EVIDENCE_DIR / system_id / f"test_output.log"
    test_log.parent.mkdir(parents=True, exist_ok=True)

    with open(test_log, "w") as log:
        result = subprocess.run(
            [str(pip_bin), "install", "pytest"],
            cwd=str(system_path),
            capture_output=True,
            text=True
        )
        result = subprocess.run(
            [str(venv_path / "bin" / "pytest"), "tests/", "-v"],
            cwd=str(system_path),
            capture_output=True,
            text=True
        )
        log.write(result.stdout)
        log.write(result.stderr)
        print(result.stdout[-500:] if result.stdout else "No output")

    print(f"✓ Setup complete for System {system_id}")
    return True


def main():
    print(f"Harness Engineering Capstone - System Setup")
    print(f"Working directory: {CAPSTONE_DIR}")
    print(f"Evidence directory: {EVIDENCE_DIR}")

    # Create evidence directories
    for system_id in SYSTEMS.keys():
        (EVIDENCE_DIR / system_id).mkdir(parents=True, exist_ok=True)

    # Set up each system
    results = {}
    for system_id, config in SYSTEMS.items():
        results[system_id] = setup_system(system_id, config)

    # Print summary
    print(f"\n{'=' * 60}")
    print("Summary")
    print(f"{'=' * 60}")
    for system_id, success in results.items():
        status = "✓" if success else "✗"
        print(f"{status} System {system_id}: {SYSTEMS[system_id]['name']}")

    return 0 if all(results.values()) else 1


if __name__ == "__main__":
    sys.exit(main())
