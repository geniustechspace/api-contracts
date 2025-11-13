fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile proto files using tonic-build
    // This generates the Rust code from proto definitions during build
    
    let proto_root = std::path::PathBuf::from("../../proto");
    
    // Tell cargo to rerun if proto files change
    println!("cargo:rerun-if-changed=../../proto/core/");
    
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
