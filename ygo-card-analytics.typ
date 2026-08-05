#let title = "Yu-Gi-Oh! Card Analytics"
#let author = "arshtyi"
#let date = datetime.today()
#let description = "Analyze Yu-Gi-Oh! cards in Typst"
#let (ot, rd) = (json("assets/ot.json"), json("assets/rd.json"))

#set document(title: title, author: author, date: date, description: description)
#set page(paper: "a4")
#set text(
    font: ((name: "Lato", covers: "latin-in-cjk"), "Noto Serif CJK SC", "Noto Sans CJK SC"),
    lang: "zh",
    region: "cn",
)
#page(align(right + horizon)[
    #block(below: 1em, text(size: 32pt, strong(title)))
    #set text(size: 15pt)
    #description
    #v(1em)
    #author\
    #datetime.today().display("[year]-[month]-[day]")
])
#page(
    footer: {
        line(length: 100%)
        v(-.5em)
        align(right)[#context counter(page).display("i")]
    },
    {
        counter(page).update(1)
        outline(title: "Contents")
        pagebreak()
        counter(page).update(1)
    },
)
#set page(footer: {
    line(length: 100%)
    v(-.5em)
    grid(
        columns: (1fr, 1fr),
        align: (left, right),
        context counter(page).display("1"),
        context {
            let headings = query(
                selector(heading.where(level: 1)).before(here()),
            )
            if headings.len() > 0 {
                let head = headings.last()
                counter(heading).display(head.numbering, at: head.location())
                h(.5em)
                head.body
            }
        },
    )
})
#set heading(numbering: "1.1.1.1.")
#show heading.where(level: 1): head => {
    align(right)[#block(below: 2em)[Chapter #context counter(heading).get().first()\ #text(size: 30pt, head.body)]]
}
#show link: it => underline(offset: 1pt, it)

