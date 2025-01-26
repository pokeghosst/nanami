pub mod parser {
    use nom::{
        bytes::complete::{tag, take_until},
        character::complete::{char, line_ending, multispace0, not_line_ending, tab},
        multi::many0,
        sequence::{delimited, preceded, tuple},
        IResult,
    };

    use crate::models::{Case, Content, Document};

    pub fn parse_title(input: &str) -> IResult<&str, &str> {
        preceded(tuple((tab, tag("title: "))), not_line_ending)(input)
    }

    fn parse_text_block(input: &str) -> IResult<&str, &str> {
        preceded(
            tuple((multispace0, tag("text"), multispace0)),
            delimited(
                char('{'),
                delimited(multispace0, take_until("}"), multispace0),
                char('}'),
            ),
        )(input)
    }

    pub fn parse_case_name(input: &str) -> IResult<&str, &str> {
        delimited(char('('), take_until(")"), char(')'))(input)
    }

    pub fn parse_case(input: &str) -> IResult<&str, Case> {
        let (input, _) = multispace0(input)?;
        let (input, _) = tag("case")(input)?;
        let (input, name) = parse_case_name(input)?;
        let (input, _) = multispace0(input)?;
        let (input, _) = char('{')(input)?;

        let (input, texts) = many0(parse_text_block)(input)?;

        let (input, _) = multispace0(input)?;
        let (input, _) = char('}')(input)?;

        Ok((input, Case { name, texts }))
    }

    pub fn parse_content(input: &str) -> IResult<&str, Content> {
        preceded(
            tuple((
                multispace0,
                tag("content"),
                multispace0,
                char('{'),
                multispace0,
            )),
            delimited(
                multispace0,
                many0(parse_case),
                tuple((multispace0, char('}'))),
            ),
        )(input)
        .map(|(next_input, cases)| (next_input, Content { cases }))
    }

    pub fn parse_document(input: &str) -> IResult<&str, Document> {
        let (input, title) = parse_title(input)?;
        let (input, _) = line_ending(input)?;
        let (input, content) = parse_content(input)?;

        Ok((input, Document { title, content }))
    }
}
