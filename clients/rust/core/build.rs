use std::path::PathBuf;
use std::process::Command;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile proto files using tonic-build
    // This generates the Rust code from proto definitions during build

    // Get the absolute path to the project root
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")?;
    let project_root = PathBuf::from(&manifest_dir)
        .join("../../..")
        .canonicalize()?;

    let proto_root = project_root.join("proto");
    let core_proto_dir = proto_root.join("core");

    // Tell cargo to rerun if proto files or buf configuration change
    println!("cargo:rerun-if-changed={}", core_proto_dir.display());
    println!(
        "cargo:rerun-if-changed={}",
        project_root.join("buf.yaml").display()
    );
    println!(
        "cargo:rerun-if-changed={}",
        project_root.join("buf.lock").display()
    );

    // Automatically discover all .proto files in the core directory
    let proto_files = discover_proto_files(&core_proto_dir)?;

    if proto_files.is_empty() {
        eprintln!(
            "cargo:warning=No .proto files found in {}",
            core_proto_dir.display()
        );
        return Err("No proto files found".into());
    }

    // List all discovered proto files for cargo rebuild detection
    for proto_file in &proto_files {
        println!("cargo:rerun-if-changed={}", proto_file.display());
    }

    // Export buf dependencies to a temporary directory
    let out_dir = std::env::var("OUT_DIR")?;
    let buf_deps_dir = PathBuf::from(&out_dir).join("buf_deps");

    // Try to export buf dependencies if buf is available
    let mut include_dirs = vec![proto_root.clone()];

    if Command::new("buf")
        .args([
            "export",
            project_root.to_str().unwrap(),
            "-o",
            buf_deps_dir.to_str().unwrap(),
        ])
        .current_dir(&project_root)
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
    {
        // If buf export succeeded, add the exported directory to includes
        include_dirs.push(buf_deps_dir);
    } else {
        eprintln!("cargo:warning=buf export failed. Proto dependencies may not be available.");
        eprintln!("cargo:warning=Install buf from https://docs.buf.build/installation");
    }

    // Compile all discovered core proto files
    tonic_build::configure()
        .build_server(false) // Client-only code generation
        .compile_protos(&proto_files, &include_dirs)?;

    Ok(())
}

/// Recursively discover all .proto files in a directory
fn discover_proto_files(dir: &PathBuf) -> Result<Vec<PathBuf>, Box<dyn std::error::Error>> {
    let mut proto_files = Vec::new();

    if !dir.exists() {
        return Err(format!("Directory does not exist: {}", dir.display()).into());
    }

    visit_dirs(dir, &mut proto_files)?;

    // Sort for consistent ordering
    proto_files.sort();

    Ok(proto_files)
}

/// Recursively visit directories to find .proto files
fn visit_dirs(dir: &PathBuf, proto_files: &mut Vec<PathBuf>) -> std::io::Result<()> {
    if dir.is_dir() {
        for entry in std::fs::read_dir(dir)? {
            let entry = entry?;
            let path = entry.path();
            if path.is_dir() {
                visit_dirs(&path, proto_files)?;
            } else if path.extension().and_then(|s| s.to_str()) == Some("proto") {
                proto_files.push(path);
            }
        }
    }
    Ok(())
}
