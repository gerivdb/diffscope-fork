// Phase D: kiva wrapper for diffscope with IRIS integration
use clap::Parser;

#[derive(Parser)]
#[command(name = "kiva")]
#[command(about = "Kiva wrapper for diffscope + IRIS signals")]
struct KivaCli {
    #[command(subcommand)]
    command: Option<KivaCommand>,
}

#[derive(clap::Subcommand)]
enum KivaCommand {
    #[command(about = "Run diffscope review with IRIS context")]
    Diffscope {
        #[arg(long, help = "Path to IRIS signals directory")]
        iris_signals: Option<String>,
    },
}

fn main() -> anyhow::Result<()> {
    let cli = KivaCli::parse();
    match cli.command {
        Some(KivaCommand::Diffscope { iris_signals }) => {
            if let Some(path) = iris_signals {
                println!("Loading IRIS signals from: {}", path);
            }
            println!("Running kiva diffscope...");
        }
        None => {
            println!("kiva - wrapper CLI for diffscope-fork");
            println!("Use --help for available commands");
        }
    }
    Ok(())
}