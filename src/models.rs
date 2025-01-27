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

pub struct Document<'a> {
    title: &'a str,
    content: Content<'a>,
}

impl<'a> Document<'a> {
    pub fn new(title: &'a str, content: Content<'a>) -> Self {
        Self { title, content }
    }

    pub fn title(&self) -> &str {
        self.title
    }

    pub fn content(&self) -> &Content {
        &self.content
    }
}

pub struct Content<'a> {
    cases: Vec<Case<'a>>,
}

impl<'a> Content<'a> {
    pub fn new(cases: Vec<Case<'a>>) -> Self {
        Self { cases }
    }

    pub fn cases(&self) -> &Vec<Case> {
        &self.cases
    }
}

pub struct Case<'a> {
    name: &'a str,
    texts: Vec<&'a str>,
}

impl<'a> Case<'a> {
    pub fn new(name: &'a str, texts: Vec<&'a str>) -> Self {
        Self { name, texts }
    }

    pub fn name(&self) -> &str {
        self.name
    }

    pub fn texts(&self) -> &Vec<&str> {
        &self.texts
    }
}
