pub mod iris {
    // Phase D : intégration IRIS signal consumer
    use anyhow::{Context, Result};
    use serde::Deserialize;
    use std::fs;
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

    pub fn load_signals<P: AsRef<Path>>(dir: P) -> Result<Vec<IrisSignal>> {
        let dir = dir.as_ref();
        let mut signals = Vec::new();
        if !dir.exists() {
            return Ok(signals);
        }
        for entry in fs::read_dir(dir)
            .with_context(|| format!("Cannot read IRIS signals dir: {}", dir.display()))?
        {
            let entry = entry?;
            let path = entry.path();
            if path.extension().map(|e| e == "json").unwrap_or(false) {
                let content = fs::read_to_string(&path)?;
                if let Ok(signal) = serde_json::from_str::<IrisSignal>(&content) {
                    signals.push(signal);
                }
            }
        }
        Ok(signals)
    }
}