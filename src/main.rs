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
use crate::parser::parse_document;
use clap::{ArgGroup, Parser};
use std::fs;

pub mod models;
pub mod parser;
pub mod renderer;

#[derive(Parser)]
#[command(
    name = "nanami",
    version,
    about = "Converts .nama markdown files to HTML5 or XHTML 1.0 Strict files and lists them in a 'directory.(x)html'.",
    arg_required_else_help = true,
    groups = [
        ArgGroup::new("format")
            .required(true)
            .args(["html5", "xhtml"]),
    ]
)]
struct Args {
    #[arg(
        long = "manual-directory",
        help = "Resets the directory.html according to the compiled files in argument order."
    )]
    manual_directory: bool,

    #[arg(
        long = "append-directory",
        help = "Appends to an existing directory.html."
    )]
    append_directory: bool,

    #[arg(
        long = "alphabetize-directory",
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

    #[arg(
        long,
        value_name = "STYLESHEETS",
        help = "CSS stylesheets(s) to include."
    )]
    style: Vec<String>,

    #[arg(long, help = "Write output without header or <body> tags.")]
    outpute: bool,

    #[arg(
        long,
        value_name = "TEMPLATE",
        help = "Use template file with {directory} and {content} placeholders."
    )]
    template: Option<String>,

    /// List of .nama files to process
    #[arg(required = true)]
    files: Vec<String>,
}

fn main() {
    match Args::try_parse() {
        Ok(args) => {
            for filename in args.files {
                let file = fs::read_to_string(&filename).unwrap();
                match parse_document(&file) {
                    Ok((_remaining, doc)) => renderer::render(
                        &doc,
                        &filename.split(".").collect::<Vec<_>>()[0],
                        args.xhtml,
                        args.outpute,
                    ),
                    Err(e) => println!("Parsing error: {}", e),
                }
            }
        }
        Err(e) => {
            eprintln!("{}", e);
        }
    };
}
