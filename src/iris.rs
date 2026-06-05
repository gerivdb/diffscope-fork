pub mod iris {
    // Phase D : intégration IRIS signal consumer
    use anyhow::Result;
    use serde::Deserialize;
    use std::path::Path;

    #[derive(Debug, Clone, Deserialize)]
    pub struct IrisSignal {
        pub source_repo: String,
        pub file: String,
        pub commit_sha: String,
        pub date: String,
        pub hits: Vec<IrisHit>,
    }

    #[derive(Debug, Clone, Deserialize)]
    pub struct IrisHit {
        #[serde(rename = "type")]
        pub hit_type: String,
        pub description: String,
    }

    pub fn load_signals<P: AsRef<Path>>(_dir: P) -> Result<Vec<IrisSignal>> {
        // Stub minimal - à implémenter selon besoin
        Ok(vec![])
    }
}