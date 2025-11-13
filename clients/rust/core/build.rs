fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile proto files using tonic-build
    // This generates the Rust code from proto definitions during build
    
    // Get the absolute path to the proto directory
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")?;
    let proto_root = std::path::PathBuf::from(&manifest_dir)
        .join("../../proto")
        .canonicalize()?;
    
    // Tell cargo to rerun if proto files change
    println!("cargo:rerun-if-changed={}", proto_root.join("core").display());
    
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
            &[proto_root],
        )?;
    
    Ok(())
}
