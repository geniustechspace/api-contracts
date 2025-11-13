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
    
    // Tell cargo to rerun if proto files or buf configuration change
    println!("cargo:rerun-if-changed={}", proto_root.join("core").display());
    println!("cargo:rerun-if-changed={}", project_root.join("buf.yaml").display());
    println!("cargo:rerun-if-changed={}", project_root.join("buf.lock").display());
    
    // List all proto files explicitly for cargo rebuild detection
    for proto_file in &[
        "core/v1/tenant.proto",
        "core/v1/context.proto",
        "core/v1/errors.proto",
        "core/v1/metadata.proto",
        "core/v1/audit.proto",
        "core/v1/health.proto",
        "core/v1/pagination.proto",
        "core/v1/types.proto",
    ] {
        println!("cargo:rerun-if-changed={}", proto_root.join(proto_file).display());
    }
    
    // Export buf dependencies to a temporary directory
    let out_dir = std::env::var("OUT_DIR")?;
    let buf_deps_dir = PathBuf::from(&out_dir).join("buf_deps");
    
    // Try to export buf dependencies if buf is available
    let mut include_dirs = vec![proto_root.clone()];
    
    if Command::new("buf")
        .args(&["export", project_root.to_str().unwrap(), "-o", buf_deps_dir.to_str().unwrap()])
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
    
    // Compile all core proto files
    tonic_build::configure()
        .build_server(false) // Client-only code generation
        .compile_protos(
            &[
                proto_root.join("core/v1/tenant.proto"),
                proto_root.join("core/v1/context.proto"),
                proto_root.join("core/v1/errors.proto"),
                proto_root.join("core/v1/metadata.proto"),
                proto_root.join("core/v1/audit.proto"),
                proto_root.join("core/v1/health.proto"),
                proto_root.join("core/v1/pagination.proto"),
                proto_root.join("core/v1/types.proto"),
            ],
            &include_dirs,
        )?;
    
    Ok(())
}
