#!/usr/bin/env python3
"""
Build script for Python packages - creates distribution-ready wheel files.

This script builds all Python packages in the workspace into installable
.whl files that can be distributed via PyPI or installed locally.
"""

import subprocess
import sys
from pathlib import Path
import shutil

# Colors for output
class Colors:
    BLUE = '\033[0;34m'
    GREEN = '\033[0;32m'
    RED = '\033[0;31m'
    NC = '\033[0m'  # No Color

def print_section(msg):
    print(f"\n{Colors.BLUE}{'='*70}{Colors.NC}")
    print(f"{Colors.BLUE}{msg}{Colors.NC}")
    print(f"{Colors.BLUE}{'='*70}{Colors.NC}\n")

def print_success(msg):
    print(f"{Colors.GREEN}✓ {msg}{Colors.NC}")

def print_error(msg):
    print(f"{Colors.RED}✗ {msg}{Colors.NC}")

def run_command(cmd, cwd=None):
    """Run a command and return success status."""
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            check=True,
            capture_output=True,
            text=True
        )
        return True, result.stdout
    except subprocess.CalledProcessError as e:
        return False, e.stderr

def main():
    # Get script directory and workspace root
    script_dir = Path(__file__).parent
    workspace_root = script_dir.parent
    python_dir = workspace_root / "clients" / "python"
    dist_dir = workspace_root / "dist" / "python"
    
    # Use venv Python if available, otherwise system Python
    venv_python = python_dir / ".venv" / "bin" / "python"
    python_cmd = str(venv_python) if venv_python.exists() else sys.executable
    
    print_section("Building Python Packages for Distribution")
    
    # Create dist directory
    dist_dir.mkdir(parents=True, exist_ok=True)
    print(f"Output directory: {dist_dir}\n")
    
    # Packages to build (validate is from pip, not built locally)
    packages = ["core", "idp", "notification"]
    
    built_packages = []
    failed_packages = []
    
    for package in packages:
        package_dir = python_dir / package
        
        if not package_dir.exists() or not (package_dir / "pyproject.toml").exists():
            print(f"Skipping {package} (no pyproject.toml)")
            continue
            
        print(f"Building {package}...")
        
        # Clean previous builds
        for cleanup_dir in ["build", "dist", f"{package}.egg-info", f"geniustechspace_{package}.egg-info"]:
            cleanup_path = package_dir / cleanup_dir
            if cleanup_path.exists():
                shutil.rmtree(cleanup_path)
        
        # Build the package
        success, output = run_command(
            [python_cmd, "-m", "build", "--wheel", "--outdir", str(dist_dir)],
            cwd=package_dir
        )
        
        if success:
            print_success(f"{package} built successfully")
            built_packages.append(package)
        else:
            print_error(f"{package} build failed:")
            print(output)
            failed_packages.append(package)
    
    # Summary
    print_section("Build Summary")
    
    if built_packages:
        print(f"{Colors.GREEN}Successfully built {len(built_packages)} package(s):{Colors.NC}")
        for pkg in built_packages:
            print(f"  ✓ {pkg}")
    
    if failed_packages:
        print(f"\n{Colors.RED}Failed to build {len(failed_packages)} package(s):{Colors.NC}")
        for pkg in failed_packages:
            print(f"  ✗ {pkg}")
    
    # List built files
    if dist_dir.exists():
        whl_files = list(dist_dir.glob("*.whl"))
        if whl_files:
            print(f"\n{Colors.BLUE}Built wheel files:{Colors.NC}")
            for whl in sorted(whl_files):
                size_mb = whl.stat().st_size / (1024 * 1024)
                print(f"  {whl.name} ({size_mb:.2f} MB)")
            
            print(f"\n{Colors.GREEN}Installation command:{Colors.NC}")
            print(f"  pip install {dist_dir}/*.whl")
    
    # Return exit code
    return 0 if not failed_packages else 1

if __name__ == "__main__":
    sys.exit(main())
