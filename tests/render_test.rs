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

use nanami::{models::Document, parser::parse_document, renderer::render};
use std::fs;

fn parse_file() -> Document {
    let nama_file = fs::read_to_string("tests/sample1.nama").unwrap();
    match parse_document(&nama_file) {
        Ok((_remaining, doc)) => doc,
        Err(e) => panic!("Parsing error: {}", e),
    }
}

#[test]
fn html_render_must_be_equal_to_benchmark() {
    let doc = parse_file(&nama_file);

    render(&doc, "sample1", false, false);

    let html_file = fs::read_to_string("sample1.html").unwrap();
    let html_benchmark = fs::read_to_string("tests/benchmark1.html").unwrap();
    let _ = fs::remove_file("sample1.html");
    assert_eq!(html_file, html_benchmark);
}
