pub mod renderer {
    use crate::models::Document;

    const HEADER_BEGIN_HTML5: &str = "<!DOCTYPE html>
    <html lang=\"en\">
        <head>
            <meta charset=\"UTF-8\">
    ";
    const TITLE_BEGIN: &str = "        <title>";
    const STYLE_SHEET_BEGIN: &str = "               <link rel=\"stylesheet\" href=\"";
    const SELF_CLOSING_TAG_END: &str = "\"/>";
    const TITLE_END: &str = "</title>\n";
    const HEADER_END: &str = "    </head>\n";
    const BODY_BEGIN: &str = "    <body>\n";
    const BODY_END: &str = "    </body>\n</html>\n";

    pub fn render(doc: &Document) -> String {
        let mut html = String::new();

        html.push_str(HEADER_BEGIN_HTML5);
        html.push_str(TITLE_BEGIN);
        html.push_str(doc.title);
        html.push_str(TITLE_END);
        html.push_str(HEADER_END);

        html.push_str(BODY_BEGIN);

        for case in &doc.content.cases {
            html.push_str("        <div class=\"case\">\n");
            html.push_str("            <h4 id=\"");
            html.push_str(case.name);
            html.push_str("\">");
            html.push_str(case.name);
            html.push_str("</h4>\n");
            for text in &case.texts {
                html.push_str("            <div class=\"text-block\">\n");
                html.push_str("                <p>");
                html.push_str(text.trim());
                html.push_str("</p>\n");
                html.push_str("            </div>\n");
            }
            html.push_str("        </div>\n");
        }
        html.push_str(BODY_END);

        html
    }
}
