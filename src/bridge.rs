pub mod phase_c {
    // Bridge minimal Phase C — VDB / ARGUS / FLUENCE / diff0-fork
    use anyhow::Result;
    use serde::Serialize;

    #[derive(Debug, Clone, Serialize, Default)]
    pub struct BridgeManifest {
        pub id: String,
        pub version: String,
        pub profile: String,
        pub fork_of: String,
        pub bridges: BridgeSet,
        pub env2_contract: Env2Contract,
        pub telemetry: Telemetry,
    }

    #[derive(Debug, Clone, Serialize, Default)]
    pub struct BridgeSet {
        pub vdb: Option<VdbBridge>,
        pub argus: Option<ArgusBridge>,
        pub fluence: Option<FluxBridge>,
        pub diff0_fork: Option<Diff0Bridge>,
    }

    #[derive(Debug, Clone, Serialize, Default)]
    pub struct VdbBridge {
        pub enabled: bool,
        pub adapter: String,
        pub sources: Vec<BridgeSource>,
    }

    #[derive(Debug, Clone, Serialize, Default)]
    pub struct ArgusBridge {
        pub enabled: bool,
        pub adapter: String,
        pub sources: Vec<BridgeSource>,
    }

    #[derive(Debug, Clone, Serialize, Default)]
    pub struct FluxBridge {
        pub enabled: bool,
        pub adapter: String,
        pub sources: Vec<BridgeSource>,
    }

    #[derive(Debug, Clone, Serialize, Default)]
    pub struct Diff0Bridge {
        pub enabled: bool,
        pub upstream_repo: String,
        pub upstream_ref: String,
        pub fork_repo: String,
        pub fork_ref: String,
        pub sync_mode: String,
    }

    #[derive(Debug, Clone, Serialize, Default)]
    pub struct BridgeSource {
        pub repo: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        pub ref_: Option<String>,
        #[serde(skip_serializing_if = "Option::is_none")]
        pub root: Option<String>,
    }

    #[derive(Debug, Clone, Serialize, Default)]
    pub struct Env2Contract {
        pub binary_target: String,
        pub output_binaries: Vec<String>,
        pub strip_binaries: bool,
        pub build_time_budget_sec: u64,
        pub expected_binary_size_mb: usize,
    }

    #[derive(Debug, Clone, Serialize, Default)]
    pub struct Telemetry {
        pub bridge_manifest_version: String,
        pub report: Report,
    }

    #[derive(Debug, Clone, Serialize, Default)]
    pub struct Report {
        pub format: String,
        pub path: String,
    }

    pub fn current() -> Result<BridgeManifest> {
        Ok(BridgeManifest {
            id: "diffscope-fork".into(),
            version: "0.1.0".into(),
            profile: "ENV2-z600".into(),
            fork_of: "diff0-fork".into(),
            bridges: BridgeSet {
                vdb: Some(VdbBridge {
                    enabled: true,
                    adapter: "manifest_only".into(),
                    sources: vec![BridgeSource {
                        repo: "gerivdb/VDB".into(),
                        ref_: Some("main".into()),
                        root: Some("VDB/ECOS-CLI".into()),
                    }],
                }),
                argus: Some(ArgusBridge {
                    enabled: true,
                    adapter: "manifest_only".into(),
                    sources: vec![BridgeSource {
                        repo: "gerivdb/ARGUS".into(),
                        ref_: Some("main".into()),
                        root: None,
                    }],
                }),
                fluence: Some(FluxBridge {
                    enabled: true,
                    adapter: "manifest_only".into(),
                    sources: vec![BridgeSource {
                        repo: "gerivdb/FLUENCE".into(),
                        ref_: Some("main".into()),
                        root: None,
                    }],
                }),
                diff0_fork: Some(Diff0Bridge {
                    enabled: true,
                    upstream_repo: "evalops/diffscope".into(),
                    upstream_ref: "main".into(),
                    fork_repo: "gerivdb/diffscope-fork".into(),
                    fork_ref: "main".into(),
                    sync_mode: "read_only".into(),
                }),
            },
            env2_contract: Env2Contract {
                binary_target: "x86_64-unknown-linux-musl".into(),
                output_binaries: vec!["diffscope".into()],
                strip_binaries: true,
                build_time_budget_sec: 900,
                expected_binary_size_mb: 18,
            },
            telemetry: Telemetry {
                bridge_manifest_version: "0.1.0".into(),
                report: Report {
                    format: "yaml".into(),
                    path: "TOPOS/envs/ENV2-z600/reports/diffscope-fork-bridge-report.yaml".into(),
                },
            },
        })
    }
}
