pub struct Document<'a> {
    title: &'a str,
    content: Content<'a>,
}

pub struct Content<'a> {
    cases: Vec<Case<'a>>,
}

pub struct Case<'a> {
    name: &'a str,
    texts: Vec<&'a str>,
}

impl<'a> Case<'a> {
    pub fn new(name: &'a str, texts: Vec<&'a str>) -> Self {
        Self { name, texts }
    }
}
