/*
nanami -- Nano Markdown compiler
Copyright (C) 2025 pokeghost

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
use clap::{ArgGroup, Command, CommandFactory, Parser};

use std::{fs, path::PathBuf};

pub mod models;
pub mod parser;
pub mod renderer;

#[derive(Parser)]
#[command(
    name = "nanami",
    version,
    about = "Converts .nama markdown files to HTML5 or XHTML 1.0 Strict files and lists them in a 'directory.(x)html'.",
    groups = [
        ArgGroup::new("format")
            .required(true)
            .multiple(false)
            .args(["html5", "xhtml"]),
    ]
)]
struct Args {
    /// List of .nama files to process
    #[arg(required = true)]
    files: Vec<String>,

    #[arg(
        long = "manual-directory",
        alias = "manual_directory",
        help = "Resets the directory.html according to the compiled files in argument order."
    )]
    manual_directory: bool,

    #[arg(
        long = "append-directory",
        alias = "append_directory",
        help = "Appends to an existing directory.html."
    )]
    append_directory: bool,

    #[arg(
        long = "alphabetize-directory",
        alias = "alphabetize_directory",
        help = "Alphabetizes an existing or new directory.html."
    )]
    alphabetize_directory: bool,

    #[arg(long, conflicts_with = "xhtml", help = "Set output format to HTML5.")]
    html5: bool,

    #[arg(
        long,
        conflicts_with = "html5",
        help = "Set output format to XHTML 1.0 Strict."
    )]
    xhtml: bool,

    #[arg(long, help = "Write output without header or <body> tags.")]
    outpute: bool,

    #[arg(
        long,
        value_name = "TEMPLATE",
        help = "Use template file with {directory} and {content} placeholders."
    )]
    template: Option<String>,
}

fn main() {
    let args = match Args::try_parse() {
        Ok(args) => args,
        Err(e) => {
            // Print user-friendly help instead of technical error
            let mut cmd = Args::command();
            cmd.print_help().unwrap();
            std::process::exit(1);
        }
    };

    // let contents = fs::read_to_string("./sample.nama")?;
    // match parse_document(&contents) {
    //     Ok((_remaining, doc)) => {
    //         println!("{}", render(&doc));
    //     }
    //     Err(e) => println!("Parsing error: {}", e),
    // }

    // Ok(())
}
