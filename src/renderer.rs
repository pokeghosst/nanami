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

use std::fs;

use crate::models::{Case, Document};

const HEADER_BEGIN_HTML5: &str =
    "<!DOCTYPE html>\n<html lang=\"en\">\n    <head>\n        <meta charset=\"UTF-8\">\n";
const HEADER_BEGIN_XHTML: &str = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n    <head>\n        <meta http-equiv=\"Content-type\" content=\"application/xhtml+xml;charset=utf-8\"/>\n";
const TITLE_BEGIN: &str = "        <title>";
const STYLE_SHEET_BEGIN: &str = "               <link rel=\"stylesheet\" href=\"";
const SELF_CLOSING_TAG_END: &str = "\"/>";
const TITLE_END: &str = "</title>\n";
const HEADER_END: &str = "    </head>\n";
const BODY_BEGIN: &str = "    <body>\n";
const BODY_END: &str = "    </body>\n</html>\n";

fn build_file(doc: &Document, xhtml: bool) -> String {
    let mut html = String::new();

    if xhtml {
        html.push_str(HEADER_BEGIN_XHTML);
    } else {
        html.push_str(HEADER_BEGIN_HTML5);
    }

    html.push_str(TITLE_BEGIN);
    html.push_str(doc.title());
    html.push_str(TITLE_END);
    html.push_str(HEADER_END);

    html.push_str(BODY_BEGIN);

    html.push_str(&build_body(doc));

    html.push_str(BODY_END);

    html
}

fn build_body(doc: &Document) -> String {
    let mut html = String::new();

    for case in doc.content().cases() {
        html.push_str("        <div class=\"case\">\n");
        html.push_str("            <h4 id=\"");
        html.push_str(case.name());
        html.push_str("\">");
        html.push_str(case.name());
        html.push_str("</h4>\n");
        for text in case.texts() {
            html.push_str("            <div class=\"text-block\">\n");
            html.push_str("                <p>");
            html.push_str(text.trim());
            html.push_str("</p>\n");
            html.push_str("            </div>\n");
        }
        html.push_str("        </div>\n");
    }

    html
}

pub fn render(doc: &Document, filename: &str, xhtml: bool, outpute: bool) {
    let file = if outpute {
        build_body(doc)
    } else {
        build_file(doc, xhtml)
    };

    if outpute {
        println!("{}", &file)
    }

    let _ = fs::write(
        filename.to_owned() + if xhtml { ".xhtml" } else { ".html" },
        file,
    );
}
